package com.example.pccc_app.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.pccc_app.data.Facility

@Composable
fun CoSoScreen(onAddClick: () -> Unit, viewModel: FacilityViewModel = viewModel()) {
    val facilities by viewModel.facilities.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("Danh sách cơ sở", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(8.dp))

        Button(onClick = onAddClick) {
            Text("Thêm cơ sở")
        }
        Spacer(Modifier.height(12.dp))

        if (facilities.isEmpty()) {
            Text("Chưa có cơ sở nào.")
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(facilities, key = { it.id }) { facility ->
                    FacilityCard(facility)
                }
            }
        }
    }
}

@Composable
fun FacilityCard(facility: Facility) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(facility.name, style = MaterialTheme.typography.titleMedium)
            Text(facility.address)
            Text("Người đứng đầu: ${facility.headName} (${facility.headPosition})")
            if (facility.businessType.isNotBlank()) {
                Text("Loại hình: ${facility.businessType}")
            }
        }
    }
}