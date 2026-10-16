package com.example.pccc_app.ui.theme


import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.example.pccc_app.ui.CoSoScreen
import com.example.pccc_app.ui.PlaceholderScreen

@Composable
fun FacilityModuleScreen(onAddFacility: () -> Unit) {
    var selected by rememberSaveable { mutableIntStateOf(0) }
    val titles = listOf("Thông tin cơ sở", "Kho biểu mẫu", "Theo dõi hồ sơ")

    Column(Modifier.fillMaxSize()) {
        TabRow(selectedTabIndex = selected) {
            titles.forEachIndexed { index, title ->
                Tab(
                    selected = selected == index,
                    onClick = { selected = index },
                    text = { Text(title, maxLines = 1) }
                )
            }
        }
        when (selected) {
            0 -> CoSoScreen(onAddClick = onAddFacility)   // tạm dùng màn hình cũ
            1 -> PlaceholderScreen("Kho biểu mẫu (PC01, PC11 – PC23)")
            else -> PlaceholderScreen("Theo dõi hồ sơ")
        }
    }
}