package com.example.pccc_app

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.ui.graphics.vector.ImageVector

/** 5 tab cấp 1, đúng thứ tự thiết kế: Trang chủ, Quản lý, Lịch, Thông báo, Cá nhân */
enum class TopTab(val route: String, val label: String, val icon: ImageVector) {
    HOME("home", "Trang chủ", Icons.Default.Home),
    FUNCTIONS("manage", "Quản lý", Icons.AutoMirrored.Filled.List),
    CALENDAR("calendar", "Lịch", Icons.Default.DateRange),
    NOTIFICATIONS("notifications", "Thông báo", Icons.Default.Notifications),
    PROFILE("profile", "Cá nhân", Icons.Default.Person)
}

/** 5 phân hệ nghiệp vụ trong tab "Quản lý" (tên và mô tả theo thiết kế) */
enum class FunctionModule(val route: String, val title: String, val description: String) {
    FACILITY("facility", "Thông tin cơ sở", "Thông tin chung, hồ sơ"),
    TEAM("team", "Đội PCCC & CNCH", "Thành viên, lịch trực"),
    EQUIPMENT("equipment", "Phương tiện", "Thiết bị, bảo dưỡng"),
    TRAINING("training", "Huấn luyện", "Kế hoạch, kết quả"),
    DRILL("drill", "Phương án & diễn tập", "Kịch bản, kết quả")
}