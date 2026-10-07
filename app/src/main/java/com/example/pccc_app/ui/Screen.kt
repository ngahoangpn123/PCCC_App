package com.example.pccc_app.ui

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Person
import androidx.compose.ui.graphics.vector.ImageVector

enum class Screen(
    val route: String,
    val label: String,
    val icon: ImageVector
) {
    TONG_QUAN("tong_quan", "Tổng quan", Icons.Filled.Home),
    CO_SO("co_so", "Cơ sở", Icons.Filled.LocationOn),
    DOI_PCCC("doi_pccc", "Đội PCCC", Icons.Filled.Person),
    THIET_BI("thiet_bi", "Thiết bị", Icons.Filled.Build),
    HOAT_DONG("hoat_dong", "Hoạt động", Icons.Filled.DateRange)
}