package com.example.pccc_app

import com.example.pccc_app.ui.FacilityFormScreen

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.compose.foundation.layout.fillMaxSize


private const val ROUTE_FACILITY_ADD = "facility_add"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val backStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = backStackEntry?.destination?.route

    val isTopLevel = TopTab.entries.any { it.route == currentRoute }
    val subTitle = FunctionModule.entries.firstOrNull { it.route == currentRoute }?.title

    val goToTab: (TopTab) -> Unit = { tab ->
        navController.navigate(tab.route) {
            popUpTo(navController.graph.findStartDestination().id) { saveState = true }
            launchSingleTop = true
            restoreState = true
        }
    }

    Scaffold(
        topBar = {
            // Màn hình con: hiện thanh tiêu đề + nút quay lại
            if (!isTopLevel && subTitle != null) {
                TopAppBar(
                    title = { Text(subTitle) },
                    navigationIcon = {
                        IconButton(onClick = { navController.popBackStack() }) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Quay lại")
                        }
                    }
                )
            }
        },
        bottomBar = {
            // Chỉ hiện thanh dưới ở 5 tab cấp 1
            if (isTopLevel) {
                NavigationBar {
                    TopTab.entries.forEach { tab ->
                        NavigationBarItem(
                            selected = currentRoute == tab.route,
                            onClick = {
                                navController.navigate(tab.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = { Icon(tab.icon, contentDescription = tab.label) },
                            label = { Text(tab.label) }
                        )
                    }
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = TopTab.HOME.route,
            modifier = Modifier.padding(padding)
        ) {
            // ---- 5 tab cấp 1 ----
            composable(TopTab.HOME.route) {
                HomeScreen(
                    onOpenModule = { navController.navigate(it.route) },
                    onOpenNotifications = { goToTab(TopTab.NOTIFICATIONS) }
                )
            }

            composable(TopTab.FUNCTIONS.route) {
                FunctionsHubScreen(onOpen = { navController.navigate(it.route) })
            }
            composable(TopTab.NOTIFICATIONS.route) { PlaceholderScreen("Trung tâm thông báo") }
            composable(TopTab.CALENDAR.route) { PlaceholderScreen("Lịch") }
            composable(TopTab.PROFILE.route) { PlaceholderScreen("Cá nhân") }

            // ---- 5 mô-đun con của "Chức năng" ----
            composable(FunctionModule.FACILITY.route) {
                FacilityModuleScreen(onAddFacility = { navController.navigate(ROUTE_FACILITY_ADD) })
            }
            composable(ROUTE_FACILITY_ADD) {
                FacilityFormScreen(onDone = { navController.popBackStack() })
            }
            composable(FunctionModule.TEAM.route) {
                TeamModuleScreen()
            }
            composable(FunctionModule.EQUIPMENT.route) {
                // TODO: gắn lại màn hình Thiết bị cũ
                PlaceholderScreen("Phương tiện, thiết bị")
            }
            composable(FunctionModule.TRAINING.route) { PlaceholderScreen("Huấn luyện, bồi dưỡng") }
            composable(FunctionModule.DRILL.route) { PlaceholderScreen("Phương án, thực tập, diễn tập") }
        }
    }
}

@Composable
fun PlaceholderScreen(text: String) {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { Text(text) }
}