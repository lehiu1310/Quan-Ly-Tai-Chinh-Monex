from __future__ import annotations

import os
import re
from datetime import date

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm, mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Flowable,
    Frame,
    KeepTogether,
    ListFlowable,
    ListItem,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)
from reportlab.platypus.tableofcontents import TableOfContents


ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUTPUT_DIR = os.path.join(ROOT_DIR, "reports")
OUTPUT_PATH = os.path.join(OUTPUT_DIR, "Bao_cao_Monex.pdf")

TEAL = colors.HexColor("#0F766E")
DARK_TEAL = colors.HexColor("#0B4F49")
INK = colors.HexColor("#17211F")
MUTED = colors.HexColor("#66736F")
LINE = colors.HexColor("#DCE7E3")
SOFT = colors.HexColor("#EEF7F4")
WARN = colors.HexColor("#E5A935")
EXPENSE = colors.HexColor("#E45D4F")
INCOME = colors.HexColor("#22A36B")


def register_fonts() -> tuple[str, str]:
    fonts_dir = r"C:\Windows\Fonts"
    regular_candidates = ["arial.ttf", "segoeui.ttf", "calibri.ttf"]
    bold_candidates = ["arialbd.ttf", "segoeuib.ttf", "calibrib.ttf"]

    def first_existing(candidates: list[str]) -> str:
        for name in candidates:
            path = os.path.join(fonts_dir, name)
            if os.path.exists(path):
                return path
        raise FileNotFoundError("Không tìm thấy font Unicode trong C:\\Windows\\Fonts")

    regular_path = first_existing(regular_candidates)
    bold_path = first_existing(bold_candidates)
    pdfmetrics.registerFont(TTFont("MonexSans", regular_path))
    pdfmetrics.registerFont(TTFont("MonexSans-Bold", bold_path))
    return "MonexSans", "MonexSans-Bold"


FONT_REGULAR, FONT_BOLD = register_fonts()


class MonexDocTemplate(BaseDocTemplate):
    def __init__(self, filename: str):
        super().__init__(
            filename,
            pagesize=A4,
            leftMargin=2.0 * cm,
            rightMargin=2.0 * cm,
            topMargin=1.8 * cm,
            bottomMargin=1.8 * cm,
            title="Báo cáo ứng dụng Monex",
            author="Monex",
        )
        frame = Frame(
            self.leftMargin,
            self.bottomMargin,
            self.width,
            self.height,
            id="normal",
        )
        self.addPageTemplates([PageTemplate(id="main", frames=[frame], onPage=draw_page)])

    def afterFlowable(self, flowable):
        if not isinstance(flowable, Paragraph):
            return
        style_name = flowable.style.name
        if style_name not in {"MonexHeading1", "MonexHeading2"}:
            return
        level = 0 if style_name == "MonexHeading1" else 1
        text = flowable.getPlainText()
        key = "heading-%s" % self.seq.nextf("heading")
        self.canv.bookmarkPage(key)
        self.canv.addOutlineEntry(text, key, level=level, closed=False)
        self.notify("TOCEntry", (level, text, self.page))


def draw_page(canvas, doc):
    if doc.page == 1:
        return
    canvas.saveState()
    width, height = A4
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.6)
    canvas.line(2.0 * cm, height - 1.25 * cm, width - 2.0 * cm, height - 1.25 * cm)
    canvas.setFont(FONT_BOLD, 8.5)
    canvas.setFillColor(TEAL)
    canvas.drawString(2.0 * cm, height - 1.0 * cm, "MONEX")
    canvas.setFont(FONT_REGULAR, 8.5)
    canvas.setFillColor(MUTED)
    canvas.drawRightString(width - 2.0 * cm, height - 1.0 * cm, "Báo cáo ứng dụng quản lý tài chính cá nhân")
    canvas.setFillColor(MUTED)
    canvas.drawCentredString(width / 2, 1.05 * cm, str(doc.page - 1))
    canvas.restoreState()


def make_styles():
    styles = getSampleStyleSheet()
    styles.add(
        ParagraphStyle(
            name="CoverTop",
            fontName=FONT_BOLD,
            fontSize=12,
            leading=16,
            alignment=TA_CENTER,
            textColor=INK,
            spaceAfter=4,
        )
    )
    styles.add(
        ParagraphStyle(
            name="CoverTitle",
            fontName=FONT_BOLD,
            fontSize=24,
            leading=31,
            alignment=TA_CENTER,
            textColor=DARK_TEAL,
            spaceBefore=30,
            spaceAfter=16,
        )
    )
    styles.add(
        ParagraphStyle(
            name="CoverMeta",
            fontName=FONT_REGULAR,
            fontSize=12.5,
            leading=18,
            alignment=TA_LEFT,
            textColor=INK,
            leftIndent=30,
            rightIndent=30,
            spaceAfter=7,
        )
    )
    styles.add(
        ParagraphStyle(
            name="TOCTitle",
            fontName=FONT_BOLD,
            fontSize=22,
            leading=28,
            alignment=TA_CENTER,
            textColor=DARK_TEAL,
            spaceAfter=22,
        )
    )
    styles.add(
        ParagraphStyle(
            name="MonexHeading1",
            fontName=FONT_BOLD,
            fontSize=16.5,
            leading=21,
            textColor=DARK_TEAL,
            spaceBefore=14,
            spaceAfter=8,
            keepWithNext=True,
        )
    )
    styles.add(
        ParagraphStyle(
            name="MonexHeading2",
            fontName=FONT_BOLD,
            fontSize=12.8,
            leading=17,
            textColor=TEAL,
            spaceBefore=9,
            spaceAfter=5,
            keepWithNext=True,
        )
    )
    styles.add(
        ParagraphStyle(
            name="BodyTextVN",
            fontName=FONT_REGULAR,
            fontSize=10.6,
            leading=15.8,
            alignment=TA_JUSTIFY,
            textColor=INK,
            spaceAfter=7,
        )
    )
    styles.add(
        ParagraphStyle(
            name="BodyBold",
            fontName=FONT_BOLD,
            fontSize=10.8,
            leading=15.8,
            textColor=INK,
            spaceAfter=6,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Small",
            fontName=FONT_REGULAR,
            fontSize=8.8,
            leading=12,
            textColor=MUTED,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Caption",
            fontName=FONT_REGULAR,
            fontSize=9.2,
            leading=12.5,
            alignment=TA_CENTER,
            textColor=MUTED,
            spaceBefore=4,
            spaceAfter=9,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Callout",
            fontName=FONT_REGULAR,
            fontSize=10.3,
            leading=14.8,
            textColor=INK,
            leftIndent=8,
            rightIndent=8,
            spaceAfter=8,
        )
    )
    return styles


STYLES = make_styles()


def p(text: str, style: str = "BodyTextVN") -> Paragraph:
    return Paragraph(text, STYLES[style])


def h1(text: str) -> Paragraph:
    return Paragraph(text, STYLES["MonexHeading1"])


def h2(text: str) -> Paragraph:
    return Paragraph(text, STYLES["MonexHeading2"])


def bullet(items: list[str]) -> ListFlowable:
    return ListFlowable(
        [
            ListItem(
                p(item),
                bulletColor=TEAL,
                leftIndent=12,
            )
            for item in items
        ],
        bulletType="bullet",
        start="circle",
        leftIndent=18,
        bulletFontName=FONT_REGULAR,
        bulletFontSize=8,
    )


def soft_table(rows, col_widths, header=True, font_size=9.2):
    table = Table(rows, colWidths=col_widths, hAlign="LEFT", repeatRows=1 if header else 0)
    base = [
        ("FONTNAME", (0, 0), (-1, -1), FONT_REGULAR),
        ("FONTSIZE", (0, 0), (-1, -1), font_size),
        ("LEADING", (0, 0), (-1, -1), font_size + 3),
        ("TEXTCOLOR", (0, 0), (-1, -1), INK),
        ("GRID", (0, 0), (-1, -1), 0.35, LINE),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]
    if header:
        base.extend(
            [
                ("BACKGROUND", (0, 0), (-1, 0), DARK_TEAL),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), FONT_BOLD),
            ]
        )
    for row_idx in range(1 if header else 0, len(rows)):
        if row_idx % 2 == 0:
            base.append(("BACKGROUND", (0, row_idx), (-1, row_idx), colors.HexColor("#F7FBFA")))
    table.setStyle(TableStyle(base))
    return table


def callout(title: str, body: str, color=TEAL):
    return KeepTogether(
        [
            Table(
                [
                    [Paragraph(title, ParagraphStyle("CalloutTitle", parent=STYLES["BodyBold"], textColor=color))],
                    [p(body, "Callout")],
                ],
                colWidths=[17.0 * cm],
                style=[
                    ("BACKGROUND", (0, 0), (-1, -1), SOFT),
                    ("BOX", (0, 0), (-1, -1), 0.6, colors.HexColor("#CBE7E1")),
                    ("LEFTPADDING", (0, 0), (-1, -1), 10),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                    ("TOPPADDING", (0, 0), (-1, -1), 8),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
                ],
            ),
            Spacer(1, 7),
        ]
    )


class ArchitectureDiagram(Flowable):
    def __init__(self, width=17 * cm, height=7.0 * cm):
        super().__init__()
        self.width = width
        self.height = height

    def draw_box(self, canv, x, y, w, h, title, body, fill, stroke=TEAL):
        canv.setFillColor(fill)
        canv.setStrokeColor(stroke)
        canv.setLineWidth(0.8)
        canv.roundRect(x, y, w, h, 8, stroke=1, fill=1)
        canv.setFillColor(INK)
        canv.setFont(FONT_BOLD, 9.5)
        canv.drawCentredString(x + w / 2, y + h - 16, title)
        canv.setFont(FONT_REGULAR, 7.6)
        canv.setFillColor(MUTED)
        for idx, line in enumerate(body):
            canv.drawCentredString(x + w / 2, y + h - 31 - idx * 10, line)

    def draw_arrow(self, canv, x1, y1, x2, y2):
        canv.setStrokeColor(TEAL)
        canv.setLineWidth(1.1)
        canv.line(x1, y1, x2, y2)
        if x2 > x1:
            canv.line(x2, y2, x2 - 5, y2 + 3)
            canv.line(x2, y2, x2 - 5, y2 - 3)

    def draw(self):
        c = self.canv
        w = self.width
        top_y = self.height - 70
        box_w = (w - 36) / 4
        gap = 12
        boxes = [
            ("Người dùng", ["Android UI", "Đăng nhập / thao tác"], SOFT),
            ("Flutter Screens", ["Overview, Search", "Savings, Reminder"], colors.HexColor("#E7F3FF")),
            ("AppState", ["Ledger theo tài khoản", "ChangeNotifier"], colors.HexColor("#FFF4D8")),
            ("Services", ["Insight, Report", "Notification, Widget"], colors.HexColor("#FDEDEA")),
        ]
        for idx, (title, body, fill) in enumerate(boxes):
            x = idx * (box_w + gap)
            self.draw_box(c, x, top_y, box_w, 54, title, body, fill)
            if idx < len(boxes) - 1:
                self.draw_arrow(c, x + box_w + 2, top_y + 27, x + box_w + gap - 3, top_y + 27)

        lower_w = (w - 18) / 2
        self.draw_box(c, 0, 18, lower_w, 50, "Lưu trữ cục bộ", ["SharedPreferences", "JSON theo username"], colors.HexColor("#F2F2F2"), MUTED)
        self.draw_box(c, lower_w + 18, 18, lower_w, 50, "Tích hợp Android", ["Local notification", "Home widget"], colors.HexColor("#F2F2F2"), MUTED)
        self.draw_arrow(c, 2 * (box_w + gap) + box_w / 2, top_y, lower_w / 2, 68)
        self.draw_arrow(c, 3 * (box_w + gap) + box_w / 2, top_y, lower_w + 18 + lower_w / 2, 68)


def cover_page(story):
    story.extend(
        [
            Spacer(1, 0.7 * cm),
            p("PHENIKAA UNIVERSITY", "CoverTop"),
            p("FACULTY OF COMPUTER SCIENCE", "CoverTop"),
            Spacer(1, 2.4 * cm),
            p("BÁO CÁO ỨNG DỤNG QUẢN LÝ TÀI CHÍNH CÁ NHÂN", "CoverTitle"),
            p("TOPIC: Thiết kế và xây dựng ứng dụng Monex", "CoverTop"),
            Spacer(1, 2.0 * cm),
            Table(
                [
                    [p("<b>Học phần:</b> Phát triển ứng dụng di động / Ứng dụng phân tán", "CoverMeta")],
                    [p("<b>Giảng viên hướng dẫn:</b> ........................................................", "CoverMeta")],
                    [p("<b>Sinh viên thực hiện:</b> ........................................................", "CoverMeta")],
                    [p("<b>Mã sinh viên:</b> ........................................................", "CoverMeta")],
                ],
                colWidths=[16.5 * cm],
                style=[
                    ("BOX", (0, 0), (-1, -1), 0.7, LINE),
                    ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F8FCFB")),
                    ("LEFTPADDING", (0, 0), (-1, -1), 10),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                    ("TOPPADDING", (0, 0), (-1, -1), 8),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
                ],
            ),
            Spacer(1, 3.0 * cm),
            Paragraph(
                "Hà Nội, Tháng 5 Năm 2026",
                ParagraphStyle(
                    "CoverBottom",
                    fontName=FONT_REGULAR,
                    fontSize=12,
                    alignment=TA_CENTER,
                    textColor=INK,
                ),
            ),
            PageBreak(),
        ]
    )


def toc_page(story):
    toc = TableOfContents()
    toc.levelStyles = [
        ParagraphStyle(
            fontName=FONT_BOLD,
            name="TOCLevel1",
            fontSize=10.5,
            leftIndent=0,
            firstLineIndent=0,
            spaceBefore=5,
            leading=14,
            textColor=INK,
        ),
        ParagraphStyle(
            fontName=FONT_REGULAR,
            name="TOCLevel2",
            fontSize=9.5,
            leftIndent=15,
            firstLineIndent=0,
            spaceBefore=2,
            leading=12,
            textColor=MUTED,
        ),
    ]
    story.extend([p("Mục lục", "TOCTitle"), toc, PageBreak()])


def report_content(story):
    story.extend(
        [
            h1("Lời mở đầu"),
            p(
                "Trong đời sống hiện đại, việc quản lý tài chính cá nhân không còn chỉ là ghi nhớ các khoản đã chi tiêu. Người dùng cần một công cụ giúp theo dõi thu nhập, chi phí, mục tiêu tiết kiệm, hóa đơn đến hạn và các cảnh báo tài chính một cách rõ ràng. Monex được xây dựng nhằm giải quyết nhu cầu đó thông qua một ứng dụng di động có giao diện trực quan, dữ liệu tách riêng theo từng tài khoản và các chức năng hỗ trợ ra quyết định chi tiêu.",
            ),
            p(
                "Báo cáo này trình bày quá trình phân tích, thiết kế và triển khai ứng dụng Monex trên nền tảng Flutter. Nội dung báo cáo đi từ tổng quan bài toán, yêu cầu chức năng, công nghệ sử dụng, kiến trúc hệ thống, thiết kế dữ liệu, luồng xử lý, đến kiểm thử và định hướng phát triển. Cách trình bày được xây dựng theo dạng báo cáo học thuật, tham khảo cấu trúc của báo cáo mẫu nhưng nội dung tập trung vào sản phẩm Monex thực tế.",
            ),
            PageBreak(),
            h1("1 TỔNG QUAN VỀ ỨNG DỤNG MONEX"),
            h2("1.1 Giới thiệu ứng dụng"),
            p(
                "Monex là ứng dụng quản lý tài chính cá nhân chạy trên Android, được phát triển bằng Flutter. Ứng dụng cho phép người dùng tạo tài khoản, đăng nhập, ghi nhận thu nhập và chi phí, quản lý mục tiêu tiết kiệm, tạo hóa đơn/lời nhắc và xem các phân tích tài chính cơ bản. Điểm quan trọng của Monex là mỗi tài khoản có một sổ dữ liệu riêng, tránh tình trạng dữ liệu thu chi của người dùng này bị lẫn sang người dùng khác.",
            ),
            p(
                "Ứng dụng được định hướng cho người dùng cá nhân, sinh viên hoặc người mới bắt đầu quản lý chi tiêu. Vì vậy giao diện cần dễ hiểu, thao tác nhanh và không tạo cảm giác phức tạp. Các thông báo trong app cũng được thiết kế lại theo hướng chỉ xuất hiện khi có dữ liệu thật, hạn chế các cảnh báo giả hoặc gợi ý chung chung.",
            ),
            h2("1.2 Mục tiêu xây dựng"),
            bullet(
                [
                    "Xây dựng ứng dụng quản lý thu nhập, chi phí, tiết kiệm và hóa đơn trên Android.",
                    "Đảm bảo tài khoản nào có dữ liệu của tài khoản đó, không dùng chung sổ thu chi.",
                    "Cung cấp trợ lý chi tiêu và thông báo thông minh dựa trên dữ liệu thật.",
                    "Bổ sung trải nghiệm người dùng tốt hơn: onboarding, dark mode, bottom navigation, skeleton loading và giao diện đăng nhập/đăng ký rõ ràng.",
                    "Hỗ trợ xuất báo cáo PDF/Excel ở mức cơ bản để phục vụ việc tổng kết tài chính.",
                ]
            ),
            h2("1.3 Phạm vi hệ thống"),
            p(
                "Phiên bản hiện tại tập trung vào mô hình ứng dụng cục bộ, dữ liệu được lưu trên thiết bị thông qua SharedPreferences dưới dạng JSON. Ứng dụng chưa sử dụng máy chủ backend hay đồng bộ cloud. Cách tiếp cận này phù hợp cho bài toán demo học phần, giúp giảm độ phức tạp triển khai nhưng vẫn thể hiện rõ thiết kế dữ liệu, phân tách tài khoản và luồng nghiệp vụ.",
            ),
            h1("2 PHÂN TÍCH YÊU CẦU HỆ THỐNG"),
            h2("2.1 Yêu cầu chức năng"),
            soft_table(
                [
                    [p("Nhóm chức năng", "BodyBold"), p("Mô tả", "BodyBold"), p("Kết quả trong Monex", "BodyBold")],
                    [p("Tài khoản", "BodyBold"), p("Đăng ký, đăng nhập, tài khoản khách và dữ liệu riêng theo username."), p("Đã triển khai bằng UserAccount và ledger riêng.")],
                    [p("Thu / chi", "BodyBold"), p("Ghi nhận thu nhập, chi phí, chọn danh mục, xem tổng quan số dư."), p("Đã có các trang thêm thu nhập, chi phí, tổng quan và tìm kiếm.")],
                    [p("Tiết kiệm", "BodyBold"), p("Tạo mục tiêu tiết kiệm, nạp tiền từng lần, rút tiền khi cần."), p("Đã sửa theo mô hình lợn đất, mục tiêu mới bắt đầu từ 0.")],
                    [p("Hóa đơn", "BodyBold"), p("Tạo khoản nhắc, theo dõi ngày đến hạn và tổng hóa đơn."), p("Đã có ReminderPage và local notification.")],
                    [p("Trợ lý / thông báo", "BodyBold"), p("Phân tích dữ liệu thu chi để cảnh báo ngân sách, hóa đơn, dòng tiền."), p("Đã dùng InsightService, chỉ cảnh báo khi có dữ liệu thật.")],
                    [p("Báo cáo", "BodyBold"), p("Xuất báo cáo tháng ra PDF/Excel và chia sẻ."), p("Đã có ReportService với pdf, printing, xlsio và share_plus.")],
                ],
                [3.5 * cm, 7.0 * cm, 6.2 * cm],
            ),
            h2("2.2 Yêu cầu phi chức năng"),
            bullet(
                [
                    "Dễ sử dụng: các thao tác chính phải xuất hiện ngay trên màn hình chính hoặc bottom sheet.",
                    "Ổn định dữ liệu: tài khoản và sổ thu chi phải còn sau khi tắt/mở app.",
                    "Phản hồi nhanh: dữ liệu cục bộ giúp thao tác thêm/sửa hiển thị ngay lập tức.",
                    "Dễ mở rộng: các phần trạng thái, báo cáo, thông báo được tách thành service riêng.",
                    "Tương thích Android Studio: project giữ cấu trúc Flutter chuẩn với thư mục android, lib và pubspec.yaml.",
                ]
            ),
            h1("3 CÁC CÔNG NGHỆ SỬ DỤNG"),
            h2("3.1 Flutter và Dart"),
            p(
                "Flutter là framework chính dùng để xây dựng giao diện đa nền tảng. Trong Monex, Flutter đảm nhiệm toàn bộ phần UI, điều hướng, theme, animation và tương tác người dùng. Dart được dùng để viết logic nghiệp vụ, quản lý trạng thái và định nghĩa các model dữ liệu như UserAccount, TransactionEntry, SavingsGoal và ReminderEntry.",
            ),
            h2("3.2 Lưu trữ cục bộ bằng SharedPreferences"),
            p(
                "SharedPreferences được dùng để lưu trạng thái ứng dụng dưới dạng JSON. Khác với cách lưu tạm trong RAM, cơ chế này giúp tài khoản, giao dịch, mục tiêu tiết kiệm, hóa đơn, danh mục và ngân sách vẫn tồn tại sau khi người dùng thoát app. Dữ liệu được tổ chức theo khóa tài khoản, vì vậy mỗi username tương ứng với một ledger riêng.",
            ),
            h2("3.3 Thông báo, widget và báo cáo"),
            soft_table(
                [
                    [p("Thư viện", "BodyBold"), p("Vai trò trong ứng dụng", "BodyBold")],
                    [p("flutter_local_notifications", "BodyBold"), p("Tạo lịch nhắc hóa đơn, xin quyền thông báo khi người dùng thực sự tạo nhắc nhở.")],
                    [p("timezone", "BodyBold"), p("Chuẩn hóa thời gian nhắc theo múi giờ Asia/Ho_Chi_Minh.")],
                    [p("home_widget", "BodyBold"), p("Hiển thị nhanh số dư hoặc thông tin tài chính trên màn hình chính Android.")],
                    [p("fl_chart", "BodyBold"), p("Vẽ biểu đồ thu/chi, xu hướng và phân tích tài chính.")],
                    [p("pdf + printing", "BodyBold"), p("Tạo và xem/chia sẻ báo cáo PDF trong ứng dụng.")],
                    [p("syncfusion_flutter_xlsio", "BodyBold"), p("Xuất báo cáo Excel (.xlsx).")],
                    [p("share_plus", "BodyBold"), p("Chia sẻ file báo cáo qua các ứng dụng khác.")],
                    [p("lottie", "BodyBold"), p("Hiển thị loading/empty state sinh động hơn.")],
                ],
                [5.2 * cm, 11.5 * cm],
            ),
            h1("4 KIẾN TRÚC TỔNG THỂ HỆ THỐNG"),
            h2("4.1 Mô hình kiến trúc"),
            p(
                "Monex sử dụng kiến trúc ứng dụng Flutter cục bộ gồm ba lớp chính: lớp giao diện, lớp trạng thái/nghiệp vụ và lớp dịch vụ/tích hợp. Lớp giao diện gồm các màn hình như LoginScreen, RegisterScreen, OverviewPage, SavingsPage, ReminderPage, NotificationPage và AnalyticsPage. Lớp trạng thái tập trung trong MonexAppState, nơi quản lý tài khoản hiện tại và ledger tương ứng. Lớp dịch vụ gồm InsightService, ReportService, NotificationService và HomeWidgetService.",
            ),
            ArchitectureDiagram(),
            p("Hình 4.1. Kiến trúc tổng thể của ứng dụng Monex", "Caption"),
            h2("4.2 Phân tách dữ liệu theo tài khoản"),
            p(
                "Một điểm quan trọng của Monex là dữ liệu không được lưu chung cho toàn bộ app. Mỗi tài khoản được ánh xạ tới một AccountLedger riêng. Ledger này chứa danh sách giao dịch, mục tiêu tiết kiệm, hóa đơn, danh mục thu nhập, danh mục chi phí và giới hạn ngân sách. Khi người dùng đăng nhập, app xác định currentLedgerKey dựa trên username và mọi thao tác sau đó chỉ tác động vào ledger tương ứng.",
            ),
            callout(
                "Nguyên tắc thiết kế dữ liệu",
                "Tài khoản nào đăng nhập thì chỉ đọc/ghi ledger của tài khoản đó. Điều này giải quyết lỗi trước đây: tạo tài khoản mới nhưng vẫn nhìn thấy chi tiêu cũ hoặc mất dữ liệu sau khi thoát ứng dụng.",
            ),
            h1("5 THIẾT KẾ CHI TIẾT HỆ THỐNG"),
            h2("5.1 Thiết kế model dữ liệu"),
            soft_table(
                [
                    [p("Model", "BodyBold"), p("Thuộc tính chính", "BodyBold"), p("Vai trò", "BodyBold")],
                    [p("UserAccount", "BodyBold"), p("username, email, password"), p("Đại diện tài khoản người dùng.")],
                    [p("TransactionEntry", "BodyBold"), p("id, type, title, category, amount, date"), p("Lưu thu nhập hoặc chi phí.")],
                    [p("SavingsGoal", "BodyBold"), p("title, targetAmount, currentAmount, deadline"), p("Mục tiêu tiết kiệm theo kiểu lợn đất.")],
                    [p("ReminderEntry", "BodyBold"), p("title, amount, reminderDate, dueDate, frequency"), p("Hóa đơn hoặc khoản cần nhắc.")],
                    [p("BudgetInfo", "BodyBold"), p("category, limit, spent, progress"), p("Tính tiến độ ngân sách theo danh mục.")],
                    [p("AccountLedger", "BodyBold"), p("transactions, goals, reminders, categories, budgetLimits"), p("Sổ dữ liệu riêng của từng tài khoản.")],
                ],
                [3.9 * cm, 6.3 * cm, 6.5 * cm],
                font_size=8.8,
            ),
            h2("5.2 Luồng đăng ký và đăng nhập"),
            p(
                "Khi người dùng đăng ký, hệ thống kiểm tra username hoặc email đã tồn tại hay chưa. Nếu hợp lệ, app tạo UserAccount mới và đồng thời tạo một AccountLedger rỗng cho tài khoản đó. Sau khi tạo xong, ứng dụng gọi saveNow để ghi dữ liệu xuống SharedPreferences trước khi chuyển sang màn hình chính. Khi đăng nhập, app tìm tài khoản khớp username/email và mật khẩu, sau đó cập nhật currentAccount và sử dụng ledger tương ứng.",
            ),
            h2("5.3 Luồng thu nhập và chi phí"),
            p(
                "Thu nhập và chi phí đều được biểu diễn bởi TransactionEntry, khác nhau ở trường TransactionType. Khi thêm chi phí mới, app tự đảm bảo danh mục tồn tại trong danh sách expenseCategories và tạo budget limit mặc định nếu danh mục chưa có ngân sách. Tổng thu nhập, tổng chi phí và số dư được tính động từ danh sách giao dịch của ledger đang đăng nhập.",
            ),
            h2("5.4 Thiết kế tiết kiệm kiểu lợn đất"),
            p(
                "Ban đầu, mục tiêu tiết kiệm trong app tự tạo một khoản tiền ban đầu bằng một phần trăm mục tiêu, gây hiểu nhầm rằng người dùng đã bỏ tiền dù chỉ mới tạo mục. Cơ chế này đã được chỉnh lại: mục tiêu mới luôn bắt đầu từ 0. Người dùng có thể nạp tiền từng lần, ví dụ hôm nay nạp 100, ngày mai nạp 200, và cũng có thể rút tiền ra khi cần mua món đồ đã tiết kiệm.",
            ),
            bullet(
                [
                    "depositSavings(goalId, amount): tăng currentAmount nhưng không vượt targetAmount.",
                    "withdrawSavings(goalId, amount): giảm currentAmount nhưng không nhỏ hơn 0.",
                    "SavingsGoalActionSheet: giao diện bottom sheet cho phép nạp/rút và chọn nhanh số tiền.",
                ]
            ),
            h2("5.5 Thiết kế trợ lý chi tiêu và thông báo thông minh"),
            p(
                "InsightService là thành phần xử lý cảnh báo thông minh. Thay vì hiển thị thông báo giả, service này chỉ tạo cảnh báo khi có dữ liệu thật, ví dụ hóa đơn đến hạn, ngân sách sắp vượt, số dư âm, chi tiêu gần bằng thu nhập, mục tiêu tiết kiệm cần tăng tốc hoặc giao dịch lớn bất thường. Cách làm này giúp thông báo có ý nghĩa hơn và tránh tạo cảm giác app chỉ có tính năng cho có.",
            ),
            soft_table(
                [
                    [p("Loại cảnh báo", "BodyBold"), p("Điều kiện sinh cảnh báo", "BodyBold")],
                    [p("Hóa đơn", "BodyBold"), p("Reminder có hạn trong 7 ngày hoặc đã quá hạn.")],
                    [p("Ngân sách", "BodyBold"), p("Danh mục đã chi từ 70% giới hạn trở lên.")],
                    [p("Dòng tiền", "BodyBold"), p("Số dư âm hoặc chi tiêu đạt từ 85% thu nhập.")],
                    [p("Mục tiêu", "BodyBold"), p("Mục tiêu gần hoàn thành hoặc deadline gần nhưng tiến độ thấp.")],
                    [p("Giao dịch bất thường", "BodyBold"), p("Khoản chi gần đây lớn hơn đáng kể so với trung bình.")],
                ],
                [4.5 * cm, 12.2 * cm],
            ),
            h1("6 TRIỂN KHAI VÀ KIỂM THỬ"),
            h2("6.1 Môi trường triển khai"),
            bullet(
                [
                    "Ngôn ngữ và framework: Dart, Flutter.",
                    "Nền tảng kiểm thử: Android Emulator chạy qua Android Studio.",
                    "Quản lý phụ thuộc: pubspec.yaml và cache runtime đặt trong thư mục project trên ổ D.",
                    "Build Android: Gradle, Android SDK và script tools/run_android_d.bat.",
                ]
            ),
            h2("6.2 Kịch bản kiểm thử chính"),
            soft_table(
                [
                    [p("Kịch bản", "BodyBold"), p("Mục tiêu kiểm thử", "BodyBold"), p("Kết quả", "BodyBold")],
                    [p("Đăng ký tài khoản mới", "BodyBold"), p("Tài khoản mới có ledger rỗng, không lấy dữ liệu tài khoản cũ."), p("Đạt")],
                    [p("Thoát app và mở lại", "BodyBold"), p("Tài khoản và giao dịch vẫn còn trong SharedPreferences."), p("Đạt")],
                    [p("Thêm thu nhập/chi phí", "BodyBold"), p("Số dư, tổng thu, tổng chi cập nhật đúng."), p("Đạt")],
                    [p("Tạo mục tiết kiệm", "BodyBold"), p("Mục tiêu mới bắt đầu từ 0."), p("Đạt")],
                    [p("Nạp/rút tiết kiệm", "BodyBold"), p("Số tiền hiện tại tăng/giảm đúng và không vượt biên."), p("Đạt")],
                    [p("Thông báo thông minh", "BodyBold"), p("Không có dữ liệu thì không hiển thị cảnh báo giả."), p("Đạt")],
                    [p("Phân tích mã nguồn", "BodyBold"), p("Chạy tools/analyze_d.bat để kiểm tra lỗi Dart."), p("No issues found")],
                ],
                [4.2 * cm, 8.5 * cm, 4.0 * cm],
                font_size=8.5,
            ),
            h2("6.3 Kết quả triển khai"),
            p(
                "Ứng dụng đã được build và cài thành công lên Android Emulator bằng script chạy trong thư mục project trên ổ D. Các chức năng chính như đăng ký, đăng nhập, thêm thu nhập, thêm chi phí, tiết kiệm, hóa đơn, thông báo và trợ lý chi tiêu đều đã được kiểm thử thủ công. Ngoài ra, mã nguồn đã được kiểm tra bằng analyzer và không phát hiện lỗi.",
            ),
            h1("7 ĐÁNH GIÁ HỆ THỐNG"),
            h2("7.1 Ưu điểm"),
            bullet(
                [
                    "Giao diện hiện đại hơn so với bản ban đầu, có bottom navigation, dark mode và các trạng thái rỗng/loading.",
                    "Dữ liệu được tách theo tài khoản và lưu bền vững sau khi thoát app.",
                    "Chức năng tiết kiệm phù hợp hơn với hành vi thực tế của người dùng.",
                    "Trợ lý chi tiêu và thông báo đã dựa trên dữ liệu thật, tránh cảnh báo lung tung.",
                    "Có nền tảng để mở rộng báo cáo PDF/Excel và home widget.",
                ]
            ),
            h2("7.2 Hạn chế"),
            bullet(
                [
                    "Dữ liệu mới chỉ lưu cục bộ, chưa đồng bộ cloud giữa nhiều thiết bị.",
                    "Mật khẩu trong bản demo còn lưu dạng plain text trong SharedPreferences, chưa có hash hoặc mã hóa.",
                    "Chưa có cơ chế xóa/sửa giao dịch đầy đủ như một app tài chính hoàn chỉnh.",
                    "Báo cáo PDF/Excel trong app mới ở mức cơ bản, chưa có biểu đồ nâng cao trong file xuất.",
                    "Thông báo local phụ thuộc vào quyền thông báo và môi trường Android của thiết bị.",
                ]
            ),
            h2("7.3 So sánh với cách lưu tạm trong RAM"),
            soft_table(
                [
                    [p("Tiêu chí", "BodyBold"), p("Lưu tạm RAM", "BodyBold"), p("SharedPreferences theo tài khoản", "BodyBold")],
                    [p("Sau khi tắt app", "BodyBold"), p("Mất tài khoản và dữ liệu."), p("Dữ liệu vẫn còn.")],
                    [p("Phân tách người dùng", "BodyBold"), p("Dễ lẫn dữ liệu nếu dùng chung state."), p("Mỗi username có ledger riêng.")],
                    [p("Độ phức tạp", "BodyBold"), p("Rất đơn giản."), p("Cần serialize/deserialize JSON.")],
                    [p("Phù hợp demo", "BodyBold"), p("Chỉ phù hợp kiểm thử nhanh."), p("Phù hợp demo có dữ liệu thật.")],
                ],
                [4.0 * cm, 6.1 * cm, 6.6 * cm],
            ),
            h1("8 HƯỚNG PHÁT TRIỂN VÀ MỞ RỘNG"),
            h2("8.1 Nâng cấp bảo mật và dữ liệu"),
            bullet(
                [
                    "Mã hóa hoặc hash mật khẩu thay vì lưu trực tiếp.",
                    "Chuyển dữ liệu sang SQLite/Hive để phù hợp khi lượng giao dịch lớn.",
                    "Bổ sung backup/restore hoặc đồng bộ cloud để dùng nhiều thiết bị.",
                    "Thêm chức năng sửa, xóa, gắn nhãn và ghi chú cho giao dịch.",
                ]
            ),
            h2("8.2 Nâng cấp phân tích tài chính"),
            bullet(
                [
                    "Biểu đồ grouped bar so sánh thu/chi theo từng tháng.",
                    "Line chart xu hướng 3-6 tháng và highlight tháng chi bất thường.",
                    "Dashboard so sánh tháng hiện tại với tháng trước theo phần trăm tăng/giảm.",
                    "Báo cáo PDF có bảng giao dịch, tổng hợp theo danh mục và biểu đồ trực quan.",
                ]
            ),
            h2("8.3 Nâng cấp trải nghiệm người dùng"),
            bullet(
                [
                    "Thêm màn cấu hình ngân sách chi tiết theo danh mục.",
                    "Tự động đề xuất hạn mức chi dựa trên thu nhập và lịch sử chi tiêu.",
                    "Cải thiện home widget để hiển thị số dư, hóa đơn gần đến hạn và mục tiêu tiết kiệm.",
                    "Bổ sung local notification theo nhiều kịch bản hơn nhưng vẫn chỉ dựa trên dữ liệu thật.",
                ]
            ),
            h1("9 KẾT LUẬN"),
            p(
                "Monex là một ứng dụng quản lý tài chính cá nhân được xây dựng theo hướng thực tế, tập trung vào các nhu cầu phổ biến như ghi thu nhập, ghi chi phí, theo dõi số dư, quản lý tiết kiệm, hóa đơn và thông báo. Qua quá trình phát triển, ứng dụng đã được cải thiện đáng kể về UI/UX, khả năng lưu dữ liệu, phân tách tài khoản và chất lượng thông báo thông minh.",
            ),
            p(
                "Kết quả triển khai cho thấy ứng dụng đã đáp ứng được các yêu cầu cốt lõi của một sản phẩm quản lý tài chính cá nhân ở mức demo hoàn chỉnh. Mặc dù vẫn còn các hạn chế như chưa có backend, chưa mã hóa dữ liệu nhạy cảm và báo cáo xuất file chưa thật sâu, Monex đã có nền tảng rõ ràng để tiếp tục phát triển thành một ứng dụng hoàn thiện hơn trong tương lai.",
            ),
            PageBreak(),
            h1("TÀI LIỆU THAM KHẢO"),
            bullet(
                [
                    "Flutter Documentation - https://docs.flutter.dev/",
                    "Dart Language Tour - https://dart.dev/language",
                    "Package shared_preferences - https://pub.dev/packages/shared_preferences",
                    "Package flutter_local_notifications - https://pub.dev/packages/flutter_local_notifications",
                    "Package pdf - https://pub.dev/packages/pdf",
                    "Package fl_chart - https://pub.dev/packages/fl_chart",
                    "Mã nguồn ứng dụng Monex trong thư mục D:/HOC_TAP/quan_ly_tai_chinh/monex.",
                ]
            ),
        ]
    )


def report_content_v2(story):
    def add_paragraphs(items):
        story.extend([p(item) for item in items])

    base_bullet = globals()["bullet"]
    base_soft_table = globals()["soft_table"]

    def bullet(items):
        story.append(base_bullet(items))

    def soft_table(rows, col_widths, header=True, font_size=9.2):
        story.append(base_soft_table(rows, col_widths, header=header, font_size=font_size))

    story.extend(
        [
            h1("Lời mở đầu"),
            p(
                "Trong đời sống hiện đại, việc quản lý tài chính cá nhân ngày càng trở nên cần thiết. Người dùng không chỉ cần biết mình đã chi bao nhiêu, mà còn cần hiểu tiền đến từ đâu, tiền đi vào những nhóm nào, khoản nào sắp đến hạn, mục tiêu tiết kiệm đang tiến triển ra sao và khi nào cần điều chỉnh hành vi chi tiêu. Nếu chỉ ghi nhớ bằng trí nhớ hoặc ghi rời rạc trong giấy tờ, người dùng rất dễ bỏ sót giao dịch, nhầm lẫn số dư và không nhận ra các thói quen chi tiêu chưa hợp lý.",
            ),
            p(
                "Monex được xây dựng như một ứng dụng quản lý tài chính cá nhân chạy trên Android, tập trung vào các thao tác gần gũi với người dùng phổ thông: tạo tài khoản, đăng nhập, thêm thu nhập, thêm chi phí, thêm danh mục, tạo mục tiêu tiết kiệm, nhắc hóa đơn, xem tổng quan, tìm kiếm giao dịch, xem biểu đồ và xuất báo cáo. Ứng dụng không hướng đến một hệ thống ngân hàng phức tạp mà hướng đến một công cụ dễ dùng, đủ rõ ràng để người dùng có thể ghi chép tài chính hằng ngày.",
            ),
            p(
                "Trong quá trình hoàn thiện, Monex đã được chỉnh sửa nhiều điểm quan trọng. Giao diện đăng nhập được làm lại để không còn cảm giác sơ sài. Dữ liệu tài khoản được lưu lại sau khi thoát ứng dụng. Mỗi tài khoản có một sổ thu chi riêng thay vì dùng chung dữ liệu. Phần tiết kiệm được thiết kế theo kiểu bỏ tiền từng lần như lợn đất. Thông báo và trợ lý tài chính cũng được điều chỉnh theo hướng chỉ đưa ra lời nhắc khi có dữ liệu thật, tránh tình trạng thông báo xuất hiện lung tung hoặc chỉ có nội dung chung chung.",
            ),
            p(
                "Báo cáo này trình bày đầy đủ quá trình phân tích, thiết kế và triển khai ứng dụng Monex. Nội dung được viết theo bố cục báo cáo học phần, bắt đầu từ tổng quan bài toán, yêu cầu hệ thống, công nghệ sử dụng, kiến trúc tổng thể, thiết kế chi tiết, triển khai kiểm thử, đánh giá, hướng phát triển và tài liệu tham khảo. Phần bìa và thông tin học phần được giữ ở dạng mẫu để người dùng có thể tự điền theo yêu cầu của giảng viên.",
            ),
            PageBreak(),
        ]
    )

    story.extend([h1("1 TỔNG QUAN VỀ ỨNG DỤNG MONEX"), h2("1.1 Bối cảnh và lý do chọn đề tài")])
    add_paragraphs(
        [
            "Tài chính cá nhân là một chủ đề rất gần với đời sống sinh viên và người đi làm. Một người có thể có nhiều nguồn tiền như lương, tiền làm thêm, tiền hỗ trợ từ gia đình hoặc các khoản thu nhỏ khác. Đồng thời, chi phí hằng ngày lại được chia thành nhiều nhóm như ăn uống, đi lại, học tập, mua sắm, giải trí, hóa đơn và tiết kiệm. Nếu không có công cụ theo dõi, người dùng thường chỉ biết cảm giác chung là mình chi nhiều, nhưng khó chỉ ra cụ thể chi nhiều ở đâu.",
            "Nhiều ứng dụng quản lý tài chính hiện nay có đầy đủ tính năng nhưng giao diện khá nặng, cần nhiều bước thiết lập và đôi khi không phù hợp với nhu cầu demo học phần. Vì vậy, đề tài Monex được chọn với mục tiêu xây dựng một ứng dụng nhỏ gọn, dễ thao tác, có đủ nhóm chức năng chính và có thể chạy trực tiếp bằng Android Studio. Ứng dụng cũng thể hiện được các kiến thức lập trình di động như quản lý trạng thái, lưu trữ cục bộ, điều hướng màn hình, biểu đồ, thông báo và xuất file.",
            "Điểm nhấn của Monex không chỉ nằm ở việc nhập giao dịch, mà còn ở cách tổ chức dữ liệu theo tài khoản. Trước khi hoàn thiện, một số chức năng chỉ hiển thị nút nhưng chưa dùng được hoặc dữ liệu tài khoản mới vẫn nhìn thấy chi tiêu cũ. Sau khi sửa, mỗi người dùng có một không gian dữ liệu riêng, giúp ứng dụng thực tế hơn và tránh lỗi nghiêm trọng khi demo.",
        ]
    )
    story.extend([h2("1.2 Giới thiệu ứng dụng")])
    add_paragraphs(
        [
            "Monex là ứng dụng quản lý tài chính cá nhân được phát triển bằng Flutter và Dart. Ứng dụng hướng đến nền tảng Android, có thể chạy trên máy ảo Android Emulator hoặc thiết bị Android thật thông qua Android Studio. Giao diện của Monex được chia thành các khu vực chính gồm màn hình xác thực tài khoản, màn hình tổng quan, màn hình thêm giao dịch, màn hình tiết kiệm, màn hình thông báo, màn hình phân tích và các màn hình nhập liệu chi tiết.",
            "Ở màn hình tổng quan, người dùng có thể nhìn nhanh số dư, tổng thu nhập, tổng chi phí, các giao dịch gần đây, trạng thái ngân sách và những lời nhắc đáng chú ý. Khi cần thêm dữ liệu, người dùng có thể thêm thu nhập, thêm chi phí, thêm mục tiêu tiết kiệm hoặc thêm hóa đơn. Các dữ liệu này sau đó được dùng để tính toán số liệu, sinh thông báo và hiển thị biểu đồ.",
            "Monex cũng có phần trợ lý tài chính nằm bên trong ứng dụng. Trợ lý này không phải chatbot AI phức tạp kết nối internet, mà là một bộ phân tích cục bộ dựa trên dữ liệu người dùng đã nhập. Cách tiếp cận này phù hợp với phạm vi bài học vì không cần backend, không cần khóa API và vẫn thể hiện được ý tưởng AI hỗ trợ nhắc nhở chi tiêu theo ngữ cảnh.",
        ]
    )
    story.extend([h2("1.3 Đối tượng sử dụng")])
    bullet(
        [
            "Sinh viên cần theo dõi tiền ăn, tiền đi lại, học phí, mua sắm và các khoản chi nhỏ hằng ngày.",
            "Người mới đi làm muốn ghi lại lương, thưởng, chi tiêu cố định và mục tiêu tiết kiệm.",
            "Người dùng cá nhân muốn một ứng dụng đơn giản, chạy cục bộ, không cần đăng nhập bằng tài khoản mạng xã hội.",
            "Người cần demo một ứng dụng Flutter có đầy đủ màn hình, lưu trữ dữ liệu và các chức năng tương tác thật.",
        ]
    )
    story.extend([h2("1.4 Mục tiêu xây dựng")])
    bullet(
        [
            "Xây dựng ứng dụng quản lý thu nhập, chi phí, tiết kiệm, hóa đơn và thông báo tài chính trên Android.",
            "Đảm bảo tài khoản nào có dữ liệu của tài khoản đó, không dùng chung sổ thu chi giữa các tài khoản.",
            "Cung cấp giao diện đẹp hơn, dễ dùng hơn và có trải nghiệm giống một ứng dụng hoàn chỉnh.",
            "Bổ sung thông báo thông minh dựa trên dữ liệu thật thay vì thông báo mặc định vô nghĩa.",
            "Hỗ trợ báo cáo PDF/Excel ở mức cơ bản để người dùng có thể tổng kết dữ liệu tài chính.",
        ]
    )
    story.extend([h2("1.5 Phạm vi hệ thống")])
    add_paragraphs(
        [
            "Phiên bản hiện tại của Monex tập trung vào ứng dụng chạy cục bộ trên thiết bị. Dữ liệu được lưu trong SharedPreferences dưới dạng JSON, phù hợp với demo học phần và không cần cấu hình máy chủ. Ứng dụng chưa triển khai cơ sở dữ liệu cloud, chưa đồng bộ nhiều thiết bị và chưa có backend xác thực thật. Đây là giới hạn có chủ ý để tập trung vào luồng chức năng và giao diện người dùng.",
            "Về mặt nghiệp vụ, Monex hỗ trợ các tính năng cốt lõi của quản lý tài chính cá nhân: ghi nhận giao dịch, phân loại danh mục, xem số dư, tìm kiếm, lọc, theo dõi ngân sách, tạo mục tiêu tiết kiệm, đặt lịch nhắc hóa đơn, nhận cảnh báo tài chính và xuất báo cáo. Các chức năng này đủ để tạo ra một vòng đời sử dụng cơ bản từ lúc tạo tài khoản đến lúc tổng kết chi tiêu.",
        ]
    )
    story.extend([PageBreak(), h1("2 PHÂN TÍCH YÊU CẦU HỆ THỐNG"), h2("2.1 Yêu cầu chức năng")])
    soft_table(
        [
            [p("Nhóm chức năng", "BodyBold"), p("Mô tả yêu cầu", "BodyBold"), p("Cách Monex đáp ứng", "BodyBold")],
            [p("Tài khoản", "BodyBold"), p("Người dùng có thể đăng ký, đăng nhập, dùng tài khoản khách và thoát tài khoản."), p("UserAccount lưu thông tin cơ bản, MonexAppState quản lý tài khoản hiện tại.")],
            [p("Lưu dữ liệu", "BodyBold"), p("Tài khoản và dữ liệu thu chi phải còn sau khi tắt app."), p("SharedPreferences lưu JSON gồm danh sách tài khoản và ledger theo username.")],
            [p("Thu nhập", "BodyBold"), p("Người dùng thêm khoản thu, chọn danh mục, nhập số tiền, ngày và ghi chú."), p("AddIncomePage tạo TransactionEntry loại income.")],
            [p("Chi phí", "BodyBold"), p("Người dùng thêm khoản chi, chọn danh mục, nhập số tiền, ngày và ghi chú."), p("AddExpensePage tạo TransactionEntry loại expense.")],
            [p("Danh mục", "BodyBold"), p("Người dùng có thể thêm danh mục mới để phân loại giao dịch."), p("Danh mục được lưu riêng cho thu nhập và chi phí trong ledger.")],
            [p("Tiết kiệm", "BodyBold"), p("Tạo mục tiêu, nạp tiền nhiều lần, rút tiền khi cần."), p("SavingsGoal lưu targetAmount và currentAmount, hỗ trợ deposit/withdraw.")],
            [p("Hóa đơn", "BodyBold"), p("Tạo hóa đơn hoặc khoản cần nhắc, theo dõi ngày đến hạn."), p("ReminderEntry và NotificationService xử lý dữ liệu nhắc nhở.")],
            [p("Phân tích", "BodyBold"), p("Xem biểu đồ thu chi, xu hướng và tổng kết theo tháng."), p("AnalyticsPage và fl_chart hiển thị số liệu trực quan.")],
            [p("Báo cáo", "BodyBold"), p("Xuất báo cáo PDF/Excel và chia sẻ file."), p("ReportService dùng pdf, printing, xlsio và share_plus.")],
        ],
        [3.5 * cm, 6.9 * cm, 6.3 * cm],
        font_size=8.2,
    )
    story.extend([h2("2.2 Yêu cầu phi chức năng")])
    bullet(
        [
            "Dễ sử dụng: các thao tác chính phải rõ ràng, ít bước và có phản hồi sau khi lưu dữ liệu.",
            "Ổn định dữ liệu: tài khoản, giao dịch, mục tiêu tiết kiệm và hóa đơn không bị mất sau khi thoát app.",
            "Tách biệt dữ liệu: mỗi tài khoản chỉ nhìn thấy dữ liệu của chính tài khoản đó.",
            "Hiệu năng phù hợp: dữ liệu cục bộ giúp thao tác thêm, lọc, tính toán và hiển thị nhanh trong phạm vi demo.",
            "Dễ mở rộng: các phần trạng thái, báo cáo, thông báo, home widget và insight được tách thành service hoặc lớp riêng.",
            "Tương thích Android Studio: project giữ cấu trúc Flutter chuẩn gồm lib, android, pubspec.yaml và các script hỗ trợ chạy trên ổ D.",
        ]
    )
    story.extend([h2("2.3 Tác nhân và ca sử dụng")])
    soft_table(
        [
            [p("Tác nhân", "BodyBold"), p("Ca sử dụng", "BodyBold"), p("Kết quả mong muốn", "BodyBold")],
            [p("Người dùng mới", "BodyBold"), p("Mở app, xem onboarding, tạo tài khoản."), p("Tài khoản được lưu và có sổ dữ liệu trống.")],
            [p("Người dùng đã có tài khoản", "BodyBold"), p("Đăng nhập lại sau khi tắt app."), p("App khôi phục đúng tài khoản và dữ liệu cũ.")],
            [p("Người ghi chi tiêu", "BodyBold"), p("Thêm khoản ăn uống, đi lại, mua sắm."), p("Số dư và biểu đồ được cập nhật.")],
            [p("Người tiết kiệm", "BodyBold"), p("Tạo mục tiêu mua xe, nạp tiền theo ngày."), p("Tiến độ tiết kiệm tăng theo từng lần nạp.")],
            [p("Người cần nhắc nợ/hóa đơn", "BodyBold"), p("Tạo lịch nhắc tiền điện, tiền nhà, học phí."), p("Thông báo chỉ xuất hiện khi có khoản thật đến hạn.")],
        ],
        [3.5 * cm, 6.5 * cm, 6.7 * cm],
        font_size=8.5,
    )
    story.extend([h2("2.4 Quy tắc nghiệp vụ chính")])
    add_paragraphs(
        [
            "Quy tắc quan trọng nhất của Monex là dữ liệu phải đi theo tài khoản. Khi người dùng tạo tài khoản mới, hệ thống phải tạo một ledger mới và không được tái sử dụng ledger của tài khoản trước. Khi người dùng đăng nhập, mọi thao tác thêm thu nhập, thêm chi phí, thêm mục tiêu hoặc thêm hóa đơn đều ghi vào ledger hiện tại.",
            "Với giao dịch, số tiền phải lớn hơn 0 và ngày giao dịch phải hợp lệ. Khi thêm chi phí với danh mục mới, ứng dụng cần đảm bảo danh mục được thêm vào danh sách chi phí để lần sau người dùng có thể chọn lại. Với tiết kiệm, số tiền hiện tại không được âm và không được vượt quá mục tiêu. Với thông báo, ứng dụng chỉ sinh cảnh báo khi có dữ liệu đủ điều kiện, ví dụ hóa đơn sắp đến hạn hoặc ngân sách gần vượt mức.",
        ]
    )
    story.extend([PageBreak(), h1("3 CÁC CÔNG NGHỆ SỬ DỤNG"), h2("3.1 Flutter và Dart")])
    add_paragraphs(
        [
            "Flutter là framework chính dùng để xây dựng toàn bộ giao diện của Monex. Nhờ cơ chế widget, ứng dụng có thể chia giao diện thành nhiều thành phần nhỏ như màn hình đăng nhập, thanh điều hướng dưới, thẻ tổng quan, ô nhập liệu, danh sách giao dịch, biểu đồ và các bottom sheet. Cách tổ chức này giúp mã nguồn dễ đọc hơn và thuận tiện khi chỉnh sửa từng phần giao diện.",
            "Dart là ngôn ngữ lập trình được sử dụng cho cả giao diện và logic nghiệp vụ. Trong Monex, Dart định nghĩa các model như UserAccount, TransactionEntry, SavingsGoal, ReminderEntry và BudgetInfo. Các model này giúp dữ liệu có cấu trúc rõ ràng, giảm việc truyền dữ liệu tùy tiện giữa các màn hình. Những phép tính như tổng thu, tổng chi, số dư, tiến độ tiết kiệm và ngân sách cũng được triển khai bằng Dart.",
            "Một ưu điểm khác của Flutter là khả năng chạy tốt trên Android Emulator trong Android Studio. Điều này phù hợp với yêu cầu của người dùng vì ứng dụng cần chạy như một app mobile thật chứ không phải web. Project Monex vẫn giữ cấu trúc chuẩn của Flutter nên có thể mở trực tiếp bằng Android Studio, chạy lệnh pub get và build APK khi cần.",
        ]
    )
    story.extend([h2("3.2 Quản lý trạng thái bằng ChangeNotifier")])
    add_paragraphs(
        [
            "Monex sử dụng MonexAppState làm lớp trung tâm để quản lý trạng thái ứng dụng. Lớp này kế thừa ChangeNotifier, cho phép giao diện tự cập nhật khi dữ liệu thay đổi. Khi người dùng thêm giao dịch, thêm mục tiêu tiết kiệm hoặc đăng nhập tài khoản khác, MonexAppState gọi notifyListeners để các màn hình liên quan được render lại.",
            "Cách làm này phù hợp với quy mô của ứng dụng. Thay vì đưa logic vào từng màn hình, các màn hình chỉ gọi hàm của AppState, ví dụ addIncome, addExpense, addGoal, depositSavings hoặc withdrawSavings. Nhờ vậy, việc lưu dữ liệu, tính toán số liệu và kiểm soát tài khoản hiện tại được tập trung, tránh lặp code và giảm lỗi sai khi nhiều màn hình cùng xử lý một loại dữ liệu.",
        ]
    )
    story.extend([h2("3.3 Lưu trữ cục bộ bằng SharedPreferences")])
    add_paragraphs(
        [
            "SharedPreferences được dùng để lưu trạng thái ứng dụng dưới dạng chuỗi JSON. Khi app khởi động, hàm load đọc dữ liệu đã lưu, khôi phục danh sách tài khoản, ledger của từng tài khoản và tài khoản hiện tại. Khi dữ liệu thay đổi, hàm saveNow hoặc cơ chế persist trong AppState ghi lại trạng thái mới.",
            "Cách lưu này có ưu điểm là đơn giản, dễ triển khai và đủ dùng cho demo. Người dùng có thể tạo tài khoản, thoát app, mở lại và vẫn thấy tài khoản cùng dữ liệu cũ. Tuy nhiên, SharedPreferences không phải lựa chọn tốt nhất cho dữ liệu lớn hoặc dữ liệu nhạy cảm. Vì vậy trong phần hướng phát triển, báo cáo đề xuất chuyển sang SQLite/Hive và bổ sung mã hóa mật khẩu.",
        ]
    )
    story.extend([h2("3.4 Thư viện giao diện, biểu đồ và file")])
    soft_table(
        [
            [p("Thư viện", "BodyBold"), p("Vai trò trong Monex", "BodyBold")],
            [p("intl", "BodyBold"), p("Định dạng tiền tệ, ngày tháng và các số liệu hiển thị trong giao diện.")],
            [p("fl_chart", "BodyBold"), p("Vẽ biểu đồ thu chi, xu hướng theo tháng và các khối phân tích tài chính.")],
            [p("table_calendar", "BodyBold"), p("Hỗ trợ chọn ngày hoặc hiển thị lịch trong các luồng liên quan đến hóa đơn.")],
            [p("lottie", "BodyBold"), p("Hiển thị trạng thái loading hoặc empty state sinh động hơn.")],
            [p("pdf + printing", "BodyBold"), p("Tạo và xem/chia sẻ báo cáo PDF trong ứng dụng.")],
            [p("syncfusion_flutter_xlsio", "BodyBold"), p("Xuất báo cáo Excel để người dùng mở bằng phần mềm bảng tính.")],
            [p("share_plus", "BodyBold"), p("Chia sẻ file báo cáo qua các ứng dụng khác trên Android.")],
        ],
        [5.2 * cm, 11.5 * cm],
    )
    story.extend([h2("3.5 Thông báo và home widget")])
    add_paragraphs(
        [
            "flutter_local_notifications được dùng để tạo thông báo cục bộ cho các hóa đơn hoặc khoản cần nhắc. Khi người dùng tạo một reminder, ứng dụng có thể lập lịch nhắc theo thời gian phù hợp. Việc thông báo dựa trên dữ liệu người dùng tạo giúp app thực tế hơn so với việc tự hiển thị các thông báo không có ngữ cảnh.",
            "home_widget được sử dụng để chuẩn bị khả năng hiển thị thông tin nhanh ngoài màn hình chính Android. Với một ứng dụng tài chính, widget có thể hiển thị số dư, khoản sắp đến hạn hoặc tiến độ mục tiêu tiết kiệm. Đây là một hướng mở rộng tốt vì người dùng không cần mở app vẫn có thể xem nhanh tình hình tài chính.",
        ]
    )
    story.extend([PageBreak(), h1("4 KIẾN TRÚC TỔNG THỂ HỆ THỐNG"), h2("4.1 Mô hình kiến trúc")])
    add_paragraphs(
        [
            "Monex sử dụng kiến trúc ứng dụng Flutter cục bộ gồm ba lớp chính: lớp giao diện, lớp trạng thái/nghiệp vụ và lớp dịch vụ/tích hợp. Lớp giao diện chịu trách nhiệm nhận thao tác từ người dùng và hiển thị dữ liệu. Lớp trạng thái quản lý tài khoản, giao dịch, mục tiêu, hóa đơn và các số liệu tổng hợp. Lớp dịch vụ xử lý những phần chuyên biệt như thông báo, insight, báo cáo và home widget.",
            "Kiến trúc này giúp ứng dụng dễ hiểu trong phạm vi học phần. Các màn hình không tự lưu dữ liệu trực tiếp mà gọi qua AppState. AppState cũng không tự tạo PDF hay tự lập lịch thông báo chi tiết, mà chuyển trách nhiệm đó cho các service tương ứng. Việc tách trách nhiệm như vậy giúp mã nguồn có thể phát triển tiếp mà không làm một file trở nên quá lớn.",
        ]
    )
    story.extend([ArchitectureDiagram(), p("Hình 4.1. Kiến trúc tổng thể của ứng dụng Monex", "Caption")])
    story.extend([h2("4.2 Cấu trúc thư mục dự án")])
    soft_table(
        [
            [p("Thư mục/tệp", "BodyBold"), p("Vai trò", "BodyBold")],
            [p("lib/main.dart", "BodyBold"), p("Điểm khởi chạy ứng dụng, tải dữ liệu ban đầu và cấu hình theme, routing.")],
            [p("lib/data", "BodyBold"), p("Chứa AppState, model dữ liệu và AppPreferences.")],
            [p("lib/screens/auths", "BodyBold"), p("Các màn hình đăng nhập, đăng ký, quên mật khẩu và trạng thái xác thực.")],
            [p("lib/screens/pages", "BodyBold"), p("Các trang nghiệp vụ chính như tổng quan, thêm giao dịch, tiết kiệm, hóa đơn, phân tích.")],
            [p("lib/screens/widgets", "BodyBold"), p("Các widget dùng lại như skeleton loading, empty state, animated money text, bottom sheet tiết kiệm.")],
            [p("lib/services", "BodyBold"), p("Dịch vụ thông báo, trợ lý tài chính, xuất báo cáo và cập nhật home widget.")],
            [p("lib/theme", "BodyBold"), p("Bộ màu, theme sáng/tối và nền ứng dụng.")],
            [p("android", "BodyBold"), p("Cấu hình Android để chạy app bằng Android Studio.")],
        ],
        [5.1 * cm, 11.6 * cm],
        font_size=8.6,
    )
    story.extend([h2("4.3 Luồng dữ liệu tổng quát")])
    add_paragraphs(
        [
            "Khi ứng dụng được mở, main gọi load để đọc dữ liệu từ SharedPreferences. Nếu đã có dữ liệu, AppState khôi phục tài khoản, ledger và các danh sách liên quan. Nếu chưa có dữ liệu, app có thể khởi tạo dữ liệu demo hoặc yêu cầu người dùng đăng ký/đăng nhập. Sau đó giao diện chính lấy dữ liệu từ AppState để hiển thị.",
            "Khi người dùng thêm một khoản chi, màn hình nhập liệu kiểm tra dữ liệu, gọi addExpense trong AppState và truyền các trường cần thiết. AppState thêm TransactionEntry vào ledger hiện tại, cập nhật danh mục nếu cần, lưu dữ liệu và thông báo cho UI. Các màn hình tổng quan, biểu đồ và thông báo đọc lại dữ liệu mới để tính số dư, ngân sách và insight.",
            "Luồng này đảm bảo dữ liệu đi theo một chiều rõ ràng: giao diện nhận nhập liệu, AppState xử lý nghiệp vụ, service hỗ trợ tác vụ chuyên biệt, sau đó giao diện cập nhật theo trạng thái mới. Đây là cách tổ chức phù hợp để tránh lỗi khi app có nhiều chức năng cùng dùng chung dữ liệu.",
        ]
    )
    story.extend([h2("4.4 Phân tách dữ liệu theo tài khoản")])
    add_paragraphs(
        [
            "Một điểm quan trọng của Monex là dữ liệu không được lưu chung cho toàn bộ app. Mỗi tài khoản được ánh xạ tới một AccountLedger riêng. Ledger này chứa danh sách giao dịch, mục tiêu tiết kiệm, hóa đơn, danh mục thu nhập, danh mục chi phí và giới hạn ngân sách. Khi người dùng đăng nhập, app xác định currentLedgerKey dựa trên username và mọi thao tác sau đó chỉ tác động vào ledger tương ứng.",
            "Thiết kế này giải quyết lỗi thường gặp trong bản demo ban đầu: tạo tài khoản mới nhưng vẫn nhìn thấy dữ liệu cũ. Với ledger riêng, tài khoản A có thể có thu nhập, chi phí và mục tiêu tiết kiệm riêng; tài khoản B đăng nhập vào sẽ thấy một bộ dữ liệu khác. Đây là điều rất quan trọng nếu app được dùng để demo trước giảng viên vì nó thể hiện đúng bản chất của hệ thống nhiều người dùng.",
        ]
    )
    story.extend([callout("Nguyên tắc thiết kế dữ liệu", "Tài khoản nào đăng nhập thì chỉ đọc/ghi ledger của tài khoản đó. Các hàm thêm thu nhập, thêm chi phí, thêm mục tiêu, thêm hóa đơn, nạp/rút tiết kiệm đều phải dùng ledger hiện tại.")])
    story.extend([PageBreak(), h1("5 THIẾT KẾ CHI TIẾT HỆ THỐNG"), h2("5.1 Thiết kế model dữ liệu")])
    soft_table(
        [
            [p("Model", "BodyBold"), p("Thuộc tính chính", "BodyBold"), p("Vai trò", "BodyBold")],
            [p("UserAccount", "BodyBold"), p("username, email, password"), p("Đại diện tài khoản người dùng.")],
            [p("TransactionEntry", "BodyBold"), p("id, type, title, category, amount, date"), p("Lưu thu nhập hoặc chi phí.")],
            [p("SavingsGoal", "BodyBold"), p("title, targetAmount, currentAmount, deadline"), p("Mục tiêu tiết kiệm theo kiểu bỏ tiền từng lần.")],
            [p("ReminderEntry", "BodyBold"), p("title, amount, reminderDate, dueDate, frequency"), p("Hóa đơn hoặc khoản cần nhắc.")],
            [p("BudgetInfo", "BodyBold"), p("category, limit, spent, progress"), p("Tính tiến độ ngân sách theo danh mục.")],
            [p("AccountLedger", "BodyBold"), p("transactions, goals, reminders, categories, budgetLimits"), p("Sổ dữ liệu riêng của từng tài khoản.")],
        ],
        [3.9 * cm, 6.3 * cm, 6.5 * cm],
        font_size=8.8,
    )
    story.extend([h2("5.2 Thiết kế đăng ký, đăng nhập và lưu phiên")])
    add_paragraphs(
        [
            "Luồng đăng ký bắt đầu từ màn hình RegisterScreen. Người dùng nhập thông tin tài khoản, ứng dụng kiểm tra dữ liệu cơ bản và xác định username hoặc email đã tồn tại hay chưa. Nếu hợp lệ, AppState tạo UserAccount mới, đồng thời tạo ledger trống cho tài khoản đó. Sau khi tạo, ứng dụng gọi saveNow để ghi dữ liệu xuống SharedPreferences trước khi chuyển sang màn hình chính.",
            "Luồng đăng nhập nằm ở LoginScreen. Người dùng có thể nhập username hoặc email cùng mật khẩu. AppState tìm tài khoản phù hợp trong danh sách đã lưu. Nếu đăng nhập thành công, currentAccount được cập nhật và currentLedgerKey trỏ đến ledger tương ứng. Việc này đảm bảo người dùng vừa đăng nhập sẽ nhìn thấy đúng dữ liệu của mình.",
            "Điểm cần nhấn mạnh là dữ liệu tài khoản không chỉ tồn tại trong RAM. Sau khi người dùng tắt app và mở lại, hàm load sẽ đọc SharedPreferences để khôi phục lại danh sách tài khoản. Điều này xử lý vấn đề trước đó là tạo tài khoản xong nhưng thoát ra vào lại thì tài khoản bị mất.",
        ]
    )
    story.extend([h2("5.3 Thiết kế giao dịch thu nhập và chi phí")])
    add_paragraphs(
        [
            "Thu nhập và chi phí trong Monex đều được biểu diễn bằng TransactionEntry. Sự khác nhau nằm ở type, có thể là income hoặc expense. Thiết kế chung một model giúp giảm trùng lặp vì cả hai loại giao dịch đều có các trường giống nhau như tiêu đề, danh mục, số tiền, ngày và ghi chú. Khi cần lọc, ứng dụng chỉ tách danh sách theo type.",
            "Khi thêm thu nhập, người dùng chọn hoặc tạo danh mục như lương, thưởng, làm thêm, quà tặng. Khi thêm chi phí, người dùng chọn hoặc tạo danh mục như ăn uống, đi lại, học tập, mua sắm, giải trí. Nếu danh mục mới chưa có trong danh sách, AppState thêm danh mục đó vào ledger hiện tại để lần sau có thể chọn lại. Cách làm này giúp app linh hoạt hơn so với danh mục cố định.",
            "Từ danh sách giao dịch, ứng dụng tính tổng thu nhập, tổng chi phí và số dư hiện tại. Các con số này được hiển thị trên màn hình tổng quan và có thể được dùng trong thông báo thông minh. Ví dụ nếu chi phí gần bằng thu nhập trong tháng, InsightService có thể đưa ra cảnh báo dòng tiền để người dùng điều chỉnh sớm.",
        ]
    )
    story.extend([h2("5.4 Thiết kế tìm kiếm và lọc giao dịch")])
    add_paragraphs(
        [
            "Tìm kiếm và lọc là chức năng quan trọng khi số lượng giao dịch tăng lên. TransactionsSearchPage cho phép người dùng tìm theo tên giao dịch hoặc danh mục, đồng thời lọc theo loại giao dịch và khoảng thời gian. Các bộ lọc như tất cả, tuần này, tháng này hoặc theo loại thu/chi giúp người dùng nhanh chóng tìm lại khoản cần kiểm tra.",
            "Về mặt xử lý, chức năng tìm kiếm không cần truy vấn cơ sở dữ liệu phức tạp vì dữ liệu hiện được lưu cục bộ trong danh sách. Ứng dụng đọc danh sách transactions của ledger hiện tại, lọc theo chuỗi tìm kiếm, type và ngày. Cách này đơn giản nhưng hiệu quả trong phạm vi demo và vẫn thể hiện được tư duy xử lý dữ liệu.",
        ]
    )
    story.extend([h2("5.5 Thiết kế tiết kiệm kiểu bỏ lợn đất")])
    add_paragraphs(
        [
            "Tiết kiệm trong Monex được thiết kế theo hướng gần với thói quen thực tế. Khi người dùng tạo mục tiêu mới, ví dụ mua xe, mua laptop hoặc đi du lịch, currentAmount ban đầu bằng 0. App không tự thêm tiền vào mục tiêu vì điều đó dễ gây hiểu nhầm rằng người dùng đã tiết kiệm dù thực tế mới chỉ tạo mục.",
            "Sau khi có mục tiêu, người dùng có thể nạp tiền từng lần. Ví dụ hôm nay có 100 thì nạp 100, hôm sau có 200 thì nạp 200. Mỗi lần nạp làm currentAmount tăng lên và thanh tiến độ thay đổi. Nếu cần sử dụng tiền trước, người dùng có thể rút bớt khỏi mục tiêu. Hàm rút tiền phải đảm bảo số tiền hiện tại không âm.",
        ]
    )
    bullet(
        [
            "depositSavings(goalId, amount): tăng currentAmount nhưng không vượt quá targetAmount.",
            "withdrawSavings(goalId, amount): giảm currentAmount nhưng không nhỏ hơn 0.",
            "SavingsGoalActionSheet: giao diện bottom sheet cho phép nạp/rút và chọn nhanh số tiền.",
        ]
    )
    story.extend([h2("5.6 Thiết kế hóa đơn và nhắc nhở")])
    add_paragraphs(
        [
            "Hóa đơn và nhắc nhở được lưu bằng ReminderEntry. Một reminder có tên khoản cần nhắc, số tiền, ngày nhắc, ngày đến hạn và tần suất. Chức năng này giúp người dùng không quên các khoản cố định như tiền điện, tiền phòng, học phí, tiền mạng hoặc các khoản nợ nhỏ.",
            "Khi người dùng tạo reminder, app có thể lập lịch thông báo cục bộ thông qua NotificationService. Tuy nhiên, phần thông báo được thiết kế cẩn thận để không tự bắn quá nhiều thông báo khi người dùng chưa tạo dữ liệu. Điều này giải quyết vấn đề thông báo trông ngơ và xuất hiện dù người dùng không làm gì.",
        ]
    )
    story.extend([h2("5.7 Thiết kế trợ lý chi tiêu và thông báo thông minh")])
    add_paragraphs(
        [
            "InsightService là phần xử lý các gợi ý và cảnh báo thông minh trong Monex. Thay vì hiển thị một câu cố định như nên tiết kiệm tiền ăn, service này đọc dữ liệu thật trong AppState để sinh nội dung phù hợp hơn. Nếu không có dữ liệu đáng chú ý, ứng dụng không nên cố tạo thông báo vì điều đó làm giảm độ tin cậy của trợ lý.",
            "Các nhóm thông báo gồm hóa đơn sắp đến hạn, ngân sách gần vượt, dòng tiền yếu, mục tiêu tiết kiệm cần chú ý và giao dịch bất thường. Mỗi thông báo có mức độ như info, good, warning hoặc danger để giao diện có thể hiển thị màu sắc phù hợp. Khi người dùng bấm vào thông báo, app có thể điều hướng đến màn hình liên quan như hóa đơn, tiết kiệm hoặc giao dịch.",
        ]
    )
    soft_table(
        [
            [p("Loại cảnh báo", "BodyBold"), p("Điều kiện sinh cảnh báo", "BodyBold"), p("Ý nghĩa với người dùng", "BodyBold")],
            [p("Hóa đơn", "BodyBold"), p("Reminder có hạn trong 7 ngày hoặc đã quá hạn."), p("Nhắc người dùng chuẩn bị tiền trước khi đến hạn.")],
            [p("Ngân sách", "BodyBold"), p("Danh mục đã chi từ 70% giới hạn trở lên."), p("Giúp giảm chi ở nhóm đang tăng nhanh.")],
            [p("Dòng tiền", "BodyBold"), p("Số dư âm hoặc chi tiêu đạt từ 85% thu nhập."), p("Cảnh báo rủi ro thiếu tiền cuối tháng.")],
            [p("Mục tiêu", "BodyBold"), p("Deadline gần nhưng tiến độ thấp hoặc mục tiêu gần hoàn thành."), p("Khuyến khích nạp thêm hoặc ghi nhận kết quả tốt.")],
            [p("Giao dịch bất thường", "BodyBold"), p("Khoản chi gần đây lớn hơn đáng kể so với trung bình."), p("Nhắc người dùng kiểm tra khoản chi lớn.")],
        ],
        [3.9 * cm, 6.6 * cm, 6.2 * cm],
        font_size=8.4,
    )
    story.extend([h2("5.8 Thiết kế báo cáo PDF và Excel")])
    add_paragraphs(
        [
            "ReportService cung cấp khả năng xuất báo cáo tháng ra PDF và Excel. Với PDF, ứng dụng có thể tạo bảng tổng hợp thu chi, danh sách giao dịch và các số liệu chính để người dùng xem hoặc chia sẻ. Với Excel, dữ liệu được xuất ở dạng bảng tính để có thể mở bằng các công cụ như Microsoft Excel hoặc Google Sheets.",
            "Trong phạm vi demo, báo cáo trong app chưa cần quá sâu như một phần mềm kế toán. Tuy nhiên, việc có chức năng xuất file giúp sản phẩm trông hoàn chỉnh hơn và đáp ứng một nhu cầu thực tế: người dùng muốn tổng kết tháng hoặc gửi dữ liệu cho người khác. Đây cũng là một điểm cộng khi thuyết trình vì thể hiện ứng dụng không chỉ nhập dữ liệu mà còn biết tạo đầu ra.",
        ]
    )
    story.extend([h2("5.9 Thiết kế UI/UX")])
    add_paragraphs(
        [
            "Giao diện Monex được cải thiện theo hướng hiện đại và dễ thao tác. Màn hình đăng nhập không còn chỉ là vài ô nhập liệu đơn giản mà có bố cục rõ ràng hơn, màu sắc đồng bộ, các điểm nhấn về tính năng và phản hồi khi đăng nhập. Onboarding được dùng để giới thiệu chức năng chính lần đầu mở app, sau đó SharedPreferences ghi nhận để không hiển thị lại quá nhiều.",
            "Bottom navigation giúp người dùng di chuyển giữa các tab chính như tổng quan, thêm giao dịch, tiết kiệm, thông báo và phân tích. AnimatedSwitcher và AnimatedMoneyText giúp số liệu thay đổi mượt hơn. Skeleton loading và empty state giúp app không bị cảm giác màn trắng khi chưa có dữ liệu. Dark mode và light mode được cấu hình bằng ThemeData để hạn chế hardcode màu trong giao diện.",
        ]
    )
    story.extend([PageBreak(), h1("6 TRIỂN KHAI VÀ KIỂM THỬ"), h2("6.1 Môi trường triển khai")])
    bullet(
        [
            "Ngôn ngữ và framework: Dart, Flutter.",
            "Công cụ phát triển: Android Studio và Android Emulator.",
            "Thư mục project chính: D:/HOC_TAP/quan_ly_tai_chinh/monex.",
            "Quản lý phụ thuộc: pubspec.yaml và các package Flutter.",
            "Build Android: Gradle, Android SDK và script hỗ trợ chạy trên ổ D.",
        ]
    )
    story.extend([h2("6.2 Các bước triển khai chính")])
    add_paragraphs(
        [
            "Bước đầu tiên là xác định đúng thư mục app. Trong thư mục quan_ly_tai_chinh có nhiều thư mục do file nén hoặc dữ liệu cũ tạo ra, nhưng ứng dụng Flutter thật nằm trong thư mục monex. Đây là thư mục có pubspec.yaml, lib, android và các file cấu hình cần thiết. Các thư mục như __MACOSX là dữ liệu phụ từ macOS và không phải app chính.",
            "Sau khi xác định thư mục đúng, các package trong pubspec.yaml được dùng để chạy pub get và build ứng dụng. Do ổ C gần hết dung lượng, quá trình cấu hình ưu tiên dùng các thư mục cache và script trên ổ D trong phạm vi có thể. Một số thành phần như Android SDK hoặc runtime hệ thống vẫn có thể nằm ở ổ C nếu đã được cài sẵn, nhưng source code và file xuất ra của Monex được đặt ở ổ D.",
            "Trong quá trình triển khai, nhiều lỗi chức năng được xử lý: tạo tài khoản không lưu, tài khoản mới dùng lại dữ liệu cũ, thêm thu nhập/chi phí không hoạt động, danh mục báo lỗi, tiết kiệm tự có tiền ban đầu và thông báo quá chung chung. Các lỗi này được sửa trong AppState, các màn hình nhập liệu, SavingsGoalActionSheet và InsightService.",
        ]
    )
    story.extend([h2("6.3 Kịch bản kiểm thử")])
    soft_table(
        [
            [p("Kịch bản", "BodyBold"), p("Mục tiêu kiểm thử", "BodyBold"), p("Kết quả mong muốn", "BodyBold")],
            [p("Đăng ký tài khoản mới", "BodyBold"), p("Tài khoản được tạo và lưu vào SharedPreferences."), p("Thoát app mở lại vẫn còn tài khoản.")],
            [p("Tách dữ liệu tài khoản", "BodyBold"), p("Tài khoản mới không thấy giao dịch tài khoản cũ."), p("Mỗi username có ledger riêng.")],
            [p("Thêm thu nhập", "BodyBold"), p("Thêm khoản thu và cập nhật tổng thu, số dư."), p("Overview hiển thị số liệu mới.")],
            [p("Thêm chi phí", "BodyBold"), p("Thêm khoản chi, danh mục và ngân sách cập nhật."), p("Tổng chi tăng, số dư giảm.")],
            [p("Thêm danh mục", "BodyBold"), p("Danh mục mới không gây lỗi khi submit."), p("Danh mục xuất hiện trong lần nhập sau.")],
            [p("Tạo tiết kiệm", "BodyBold"), p("Mục tiêu mới bắt đầu từ 0."), p("Không tự có tiền tiết kiệm.")],
            [p("Nạp/rút tiết kiệm", "BodyBold"), p("Số tiền thay đổi đúng và không vượt biên."), p("Tiến độ cập nhật chính xác.")],
            [p("Tạo hóa đơn", "BodyBold"), p("Reminder được lưu và có thể sinh thông báo."), p("Danh sách hóa đơn cập nhật.")],
            [p("Thông báo thông minh", "BodyBold"), p("Không có dữ liệu thì không tạo cảnh báo giả."), p("Chỉ hiện khi có điều kiện thật.")],
            [p("Xuất báo cáo", "BodyBold"), p("PDF/Excel có thể tạo và chia sẻ."), p("File được sinh ra từ dữ liệu app.")],
        ],
        [3.9 * cm, 7.2 * cm, 5.6 * cm],
        font_size=8.2,
    )
    story.extend([h2("6.4 Kiểm thử giao diện")])
    add_paragraphs(
        [
            "Kiểm thử giao diện được thực hiện thủ công trên Android Emulator. Các màn hình cần được mở lần lượt để kiểm tra nút bấm, điều hướng, nhập liệu và trạng thái sau khi lưu. Với một ứng dụng quản lý tài chính, kiểm thử thủ công rất quan trọng vì nhiều lỗi không chỉ nằm ở code mà còn nằm ở trải nghiệm, ví dụ nút có nhưng không làm gì, nhập xong không thấy dữ liệu hoặc thông báo không đúng ngữ cảnh.",
            "Các màn hình cần chú ý gồm LoginScreen, RegisterScreen, OverviewPage, AddIncomePage, AddExpensePage, AddTransactionPage, SavingsPage, ReminderPage, NotificationPage và AnalyticsPage. Ngoài ra, cần kiểm tra giao diện trong cả dark mode và light mode để bảo đảm màu chữ, màu nền, card và biểu đồ vẫn dễ đọc.",
        ]
    )
    story.extend([h2("6.5 Kết quả triển khai")])
    add_paragraphs(
        [
            "Sau khi hoàn thiện, Monex có thể chạy trên Android Studio dưới dạng ứng dụng Android. Các chức năng chính đã có luồng thao tác thật thay vì chỉ hiển thị nút. Người dùng có thể tạo tài khoản, đăng nhập lại, thêm dữ liệu tài chính, tạo tiết kiệm, tạo hóa đơn và xem các phân tích cơ bản.",
            "Mã nguồn cũng được kiểm tra bằng công cụ phân tích của Dart/Flutter. Việc analyzer không báo lỗi giúp tăng độ tin cậy trước khi demo. Dù vậy, kiểm thử tự động chưa được xây dựng đầy đủ, vì vậy khi phát triển tiếp nên bổ sung unit test cho AppState, InsightService và ReportService.",
        ]
    )
    story.extend([PageBreak(), h1("7 ĐÁNH GIÁ HỆ THỐNG"), h2("7.1 Ưu điểm")])
    bullet(
        [
            "Ứng dụng có đầy đủ luồng chính của một app quản lý tài chính cá nhân: tài khoản, giao dịch, tiết kiệm, hóa đơn, thông báo, phân tích và báo cáo.",
            "Giao diện đã được cải thiện đáng kể so với bản ban đầu, có màu sắc thống nhất, bottom navigation, dark mode, onboarding và trạng thái loading/empty.",
            "Dữ liệu được tách theo tài khoản, giúp demo nhiều người dùng rõ ràng hơn và tránh lỗi dùng chung sổ thu chi.",
            "Dữ liệu được lưu lại sau khi thoát ứng dụng, giải quyết vấn đề tài khoản bị mất khi mở lại app.",
            "Phần tiết kiệm mô phỏng được hành vi bỏ tiền từng lần, phù hợp với cách người dùng thực tế tiết kiệm để mua một món đồ.",
            "Trợ lý tài chính và thông báo đã có logic dựa trên dữ liệu thật, không chỉ hiển thị các câu gợi ý cố định.",
        ]
    )
    story.extend([h2("7.2 Hạn chế")])
    bullet(
        [
            "Dữ liệu mới chỉ lưu cục bộ, chưa đồng bộ cloud giữa nhiều thiết bị.",
            "Mật khẩu trong bản demo còn lưu ở dạng đơn giản, chưa có hash hoặc mã hóa đúng chuẩn bảo mật.",
            "Chưa có backend xác thực, vì vậy phần tài khoản phù hợp demo hơn là triển khai thật cho người dùng rộng rãi.",
            "Báo cáo PDF/Excel trong app mới ở mức cơ bản, chưa có biểu đồ và định dạng nâng cao như một hệ thống chuyên nghiệp.",
            "Thông báo local phụ thuộc vào quyền thông báo và cấu hình Android của thiết bị.",
            "Chưa có bộ test tự động đầy đủ để kiểm tra toàn bộ nghiệp vụ sau mỗi lần sửa code.",
        ]
    )
    story.extend([h2("7.3 So sánh trước và sau khi cải tiến")])
    soft_table(
        [
            [p("Nội dung", "BodyBold"), p("Trước khi cải tiến", "BodyBold"), p("Sau khi cải tiến", "BodyBold")],
            [p("Đăng nhập", "BodyBold"), p("Giao diện đơn giản, cảm giác làm cho có."), p("Giao diện rõ hơn, có phản hồi và trải nghiệm tốt hơn.")],
            [p("Tài khoản", "BodyBold"), p("Tài khoản mới có thể mất sau khi thoát app."), p("Tài khoản được lưu và khôi phục bằng SharedPreferences.")],
            [p("Dữ liệu", "BodyBold"), p("Có nguy cơ dùng chung chi tiêu giữa các tài khoản."), p("Mỗi tài khoản có ledger riêng.")],
            [p("Thêm dữ liệu", "BodyBold"), p("Một số nút hiện ra nhưng chức năng chưa chạy."), p("Thu nhập, chi phí, danh mục, hóa đơn, tiết kiệm có luồng xử lý thật.")],
            [p("Tiết kiệm", "BodyBold"), p("Tạo mục tiêu xong app hiển thị như đã bỏ tiền."), p("Mục tiêu bắt đầu từ 0, người dùng nạp/rút từng lần.")],
            [p("Thông báo", "BodyBold"), p("Thông báo chung chung, xuất hiện không đúng ngữ cảnh."), p("Cảnh báo dựa trên hóa đơn, ngân sách, dòng tiền, mục tiêu và giao dịch thật.")],
        ],
        [3.5 * cm, 6.5 * cm, 6.7 * cm],
        font_size=8.2,
    )
    story.extend([h2("7.4 Mức độ đáp ứng mục tiêu")])
    add_paragraphs(
        [
            "Xét theo mục tiêu ban đầu, Monex đã đáp ứng được yêu cầu xây dựng một ứng dụng tài chính cá nhân có khả năng chạy trên Android Studio. Ứng dụng có giao diện sử dụng được, có lưu dữ liệu, có phân tách tài khoản và có nhiều màn hình nghiệp vụ. Đây là những điểm quan trọng để chứng minh sản phẩm không chỉ là thiết kế giao diện tĩnh.",
            "Tuy nhiên, Monex vẫn là một phiên bản demo học phần. Để trở thành sản phẩm thật, ứng dụng cần bổ sung bảo mật, đồng bộ dữ liệu, chỉnh sửa/xóa giao dịch đầy đủ, backup, test tự động và xử lý lỗi kỹ hơn. Những hạn chế này không làm giảm giá trị demo hiện tại, nhưng là cơ sở để định hướng phát triển tiếp.",
        ]
    )
    story.extend([PageBreak(), h1("8 HƯỚNG PHÁT TRIỂN VÀ MỞ RỘNG"), h2("8.1 Nâng cấp bảo mật và lưu trữ")])
    bullet(
        [
            "Hash mật khẩu thay vì lưu trực tiếp trong SharedPreferences.",
            "Mã hóa dữ liệu nhạy cảm nếu vẫn lưu cục bộ trên thiết bị.",
            "Chuyển dữ liệu sang SQLite hoặc Hive khi số lượng giao dịch lớn hơn.",
            "Bổ sung backup/restore để người dùng không mất dữ liệu khi đổi máy.",
            "Xây dựng backend và đăng nhập thật nếu muốn triển khai sản phẩm nhiều người dùng.",
        ]
    )
    story.extend([h2("8.2 Nâng cấp phân tích tài chính")])
    add_paragraphs(
        [
            "Phần phân tích có thể phát triển mạnh hơn bằng cách thêm grouped bar chart so sánh thu và chi theo từng tháng. Biểu đồ này giúp người dùng nhìn nhanh tháng nào thu cao, tháng nào chi cao và tháng nào có nguy cơ mất cân bằng. Ngoài ra, line chart xu hướng 3 đến 6 tháng có thể giúp phát hiện giai đoạn chi tiêu tăng bất thường.",
            "Một chức năng hữu ích khác là dashboard so sánh tháng hiện tại với tháng trước. Ví dụ ứng dụng có thể hiển thị chi tiêu tháng này tăng 18% so với tháng trước, nhóm ăn uống tăng mạnh nhất, còn tiết kiệm giảm. Những nhận xét này giúp trợ lý tài chính thông minh hơn và gần với nhu cầu thực tế của người dùng.",
        ]
    )
    story.extend([h2("8.3 Nâng cấp thông báo và trợ lý tài chính")])
    add_paragraphs(
        [
            "Thông báo hiện tại đã chuyển từ kiểu chung chung sang dựa trên dữ liệu thật, nhưng vẫn có thể phát triển tiếp. Ứng dụng có thể cho phép người dùng cấu hình mức nhạy của cảnh báo, ví dụ cảnh báo ngân sách khi đạt 70%, 80% hoặc 90%. Người dùng cũng có thể bật/tắt từng nhóm thông báo để tránh bị làm phiền.",
            "Trợ lý tài chính có thể được nâng cấp thành phần phân tích có giải thích rõ ràng hơn. Thay vì chỉ đưa ra kết luận, trợ lý nên nêu lý do: danh mục ăn uống chiếm 42% tổng chi tháng này, cao hơn trung bình 3 tháng gần nhất nên cần giảm. Cách giải thích này làm thông báo đáng tin hơn và có giá trị hơn.",
        ]
    )
    story.extend([h2("8.4 Nâng cấp báo cáo PDF/Excel")])
    bullet(
        [
            "Thêm bảng tổng hợp thu chi theo danh mục trong file PDF.",
            "Thêm biểu đồ tròn hoặc biểu đồ cột vào báo cáo PDF.",
            "Cho phép chọn khoảng thời gian xuất báo cáo: tuần, tháng, quý hoặc tùy chỉnh.",
            "Xuất Excel nhiều sheet gồm giao dịch, danh mục, ngân sách và mục tiêu tiết kiệm.",
            "Cho phép chia sẻ báo cáo qua email, Zalo, Messenger hoặc lưu vào thư mục tải xuống.",
        ]
    )
    story.extend([h2("8.5 Nâng cấp trải nghiệm người dùng")])
    add_paragraphs(
        [
            "Trải nghiệm người dùng có thể tiếp tục được cải thiện bằng cách thêm thao tác vuốt để chuyển tab, badge hiển thị số thông báo chưa đọc, hiệu ứng Hero khi mở chi tiết giao dịch và AnimatedSwitcher cho các số liệu thay đổi. Những chi tiết nhỏ này làm app có cảm giác mượt và chuyên nghiệp hơn.",
            "Ngoài ra, app có thể bổ sung màn cấu hình ngân sách chi tiết theo danh mục, màn thống kê mục tiêu tiết kiệm và chức năng sửa/xóa giao dịch. Đây là các tính năng người dùng tự nhiên sẽ mong đợi khi sử dụng một app tài chính lâu dài.",
        ]
    )
    story.extend([PageBreak(), h1("9 KẾT LUẬN")])
    add_paragraphs(
        [
            "Monex là một ứng dụng quản lý tài chính cá nhân được xây dựng theo hướng thực tế, tập trung vào các nhu cầu phổ biến như ghi thu nhập, ghi chi phí, theo dõi số dư, quản lý tiết kiệm, hóa đơn và thông báo. Qua quá trình phát triển, ứng dụng đã được cải thiện đáng kể về UI/UX, khả năng lưu dữ liệu, phân tách tài khoản và chất lượng thông báo thông minh.",
            "Điểm nổi bật của Monex là ứng dụng đã chuyển từ trạng thái có nhiều nút nhưng chức năng chưa hoàn chỉnh sang một sản phẩm demo có luồng sử dụng rõ ràng. Người dùng có thể tạo tài khoản, lưu tài khoản, thêm dữ liệu, xem lại dữ liệu và nhận các gợi ý dựa trên dữ liệu đã nhập. Đây là nền tảng quan trọng để ứng dụng có thể được trình bày trong báo cáo học phần và demo trên Android Studio.",
            "Mặc dù vẫn còn các hạn chế như chưa có backend, chưa mã hóa mật khẩu và báo cáo xuất file chưa thật sâu, Monex đã thể hiện được quá trình phân tích yêu cầu, thiết kế dữ liệu, xây dựng giao diện, triển khai logic nghiệp vụ và kiểm thử cơ bản. Trong tương lai, nếu được bổ sung bảo mật, cơ sở dữ liệu mạnh hơn, đồng bộ cloud và phân tích nâng cao, Monex có thể phát triển thành một ứng dụng tài chính cá nhân hoàn thiện hơn.",
        ]
    )
    story.extend([h1("TÀI LIỆU THAM KHẢO")])
    bullet(
        [
            "Flutter Documentation - https://docs.flutter.dev/",
            "Dart Language Tour - https://dart.dev/language",
            "Package shared_preferences - https://pub.dev/packages/shared_preferences",
            "Package flutter_local_notifications - https://pub.dev/packages/flutter_local_notifications",
            "Package home_widget - https://pub.dev/packages/home_widget",
            "Package pdf - https://pub.dev/packages/pdf",
            "Package printing - https://pub.dev/packages/printing",
            "Package syncfusion_flutter_xlsio - https://pub.dev/packages/syncfusion_flutter_xlsio",
            "Package fl_chart - https://pub.dev/packages/fl_chart",
            "Package share_plus - https://pub.dev/packages/share_plus",
            "Mã nguồn ứng dụng Monex trong thư mục D:/HOC_TAP/quan_ly_tai_chinh/monex.",
        ]
    )


def build_pdf():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    doc = MonexDocTemplate(OUTPUT_PATH)
    story = []
    cover_page(story)
    toc_page(story)
    report_content_v2(story)
    doc.multiBuild(story)


if __name__ == "__main__":
    build_pdf()
    print(OUTPUT_PATH)
