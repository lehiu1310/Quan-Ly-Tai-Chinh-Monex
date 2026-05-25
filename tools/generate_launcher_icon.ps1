$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$project = Resolve-Path (Join-Path $PSScriptRoot "..")
$icons = @(
    @{ Path = "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"; Size = 48 },
    @{ Path = "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"; Size = 72 },
    @{ Path = "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"; Size = 96 },
    @{ Path = "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"; Size = 144 },
    @{ Path = "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"; Size = 192 }
)

function New-RoundedPath {
    param(
        [System.Drawing.RectangleF] $Rect,
        [float] $Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $path.AddArc($Rect.X, $Rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($Rect.Right - $diameter, $Rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($Rect.Right - $diameter, $Rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($Rect.X, $Rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

foreach ($icon in $icons) {
    $size = [int]$icon.Size
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $rect = New-Object System.Drawing.RectangleF 0, 0, $size, $size
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush -ArgumentList @(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 13, 63, 58),
        [System.Drawing.Color]::FromArgb(255, 20, 108, 99),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $graphics.FillRectangle($bg, $rect)

    $stripePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(32, 255, 255, 255)), ([Math]::Max(1, $size * 0.018))
    for ($x = -$size; $x -lt $size * 1.2; $x += $size * 0.28) {
        $graphics.DrawLine($stripePen, $x, 0, $x + $size, $size)
    }

    $cardRect = New-Object System.Drawing.RectangleF ($size * 0.18), ($size * 0.19), ($size * 0.64), ($size * 0.62)
    $cardPath = New-RoundedPath $cardRect ($size * 0.16)
    $graphics.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(42, 255, 255, 255))), $cardPath)
    $graphics.DrawPath((New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(58, 255, 255, 255)), ([Math]::Max(1, $size * 0.012))), $cardPath)

    $fontSize = $size * 0.42
    $font = New-Object System.Drawing.Font "Arial", $fontSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $text = "M"
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $graphics.DrawString($text, $font, [System.Drawing.Brushes]::White, $rect, $format)

    $dotBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 229, 169, 53))
    $graphics.FillEllipse($dotBrush, $size * 0.67, $size * 0.23, $size * 0.09, $size * 0.09)
    $graphics.FillEllipse($dotBrush, $size * 0.76, $size * 0.34, $size * 0.045, $size * 0.045)

    $out = Join-Path $project $icon.Path
    $bitmap.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $bitmap.Dispose()
}

Write-Host "Generated Monex launcher icons."
