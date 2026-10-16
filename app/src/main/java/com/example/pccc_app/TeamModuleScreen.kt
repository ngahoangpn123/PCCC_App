package com.example.pccc_app

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.example.pccc_app.ui.theme.PcccColors

@Composable
fun TeamModuleScreen() {
    var tab by rememberSaveable { mutableIntStateOf(0) }
    var selectedDay by rememberSaveable { mutableIntStateOf(TODAY_INDEX) }
    var pendingMemberId by rememberSaveable { mutableStateOf<String?>(null) }
    var showAlerts by rememberSaveable { mutableStateOf(false) }

    val alerts = remember { buildTeamAlerts() }
    val titles = listOf("Thành viên", "Lịch trực")

    Column(Modifier.fillMaxSize()) {
        TabRow(
            selectedTabIndex = tab,
            containerColor = Color.White,
            contentColor = PcccColors.Burgundy
        ) {
            titles.forEachIndexed { index, title ->
                Tab(
                    selected = tab == index,
                    onClick = { tab = index },
                    text = { Text(title, maxLines = 1) }
                )
            }
        }
        AlertStrip(alerts = alerts, onClick = { showAlerts = true })
        when (tab) {
            0 -> TeamMembersTab(
                initialOpenId = pendingMemberId,
                onSheetClosed = { pendingMemberId = null }
            )
            else -> DutyScheduleTab(
                selectedDay = selectedDay,
                onDayChange = { selectedDay = it }
            )
        }
    }

    if (showAlerts) {
        AlertSheet(
            alerts = alerts,
            onDismiss = { showAlerts = false },
            onOpen = { alert ->
                showAlerts = false
                alert.shiftDay?.let { day ->
                    selectedDay = day
                    tab = 1
                }
                alert.memberId?.let { id ->
                    pendingMemberId = id
                    tab = 0
                }
            }
        )
    }
}