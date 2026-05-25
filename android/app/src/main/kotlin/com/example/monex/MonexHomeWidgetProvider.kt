package com.example.monex

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class MonexHomeWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.monex_home_widget).apply {
            val openAppIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.monex_widget_root, openAppIntent)
            setTextViewText(R.id.monex_widget_account, widgetData.getString("account", "Monex"))
            setTextViewText(R.id.monex_widget_balance, widgetData.getString("balance", "$0"))
            setTextViewText(R.id.monex_widget_income, widgetData.getString("income", "$0"))
            setTextViewText(R.id.monex_widget_expense, widgetData.getString("expense", "$0"))
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
