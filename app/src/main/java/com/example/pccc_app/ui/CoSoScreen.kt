package com.example.pccc_app.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.pccc_app.data.Facility

@Composable
fun CoSoScreen(onAddClick: () -> Unit, viewModel: FacilityViewModel = viewModel()) {
    val facilities by viewModel.facilities.collectAsState()

    // Cơ sở đang chờ xác nhận xóa (null = không có hộp thoại nào)
    var toDelete by remember { mutableStateOf<Facility?>(null) }

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
                    FacilityCard(
                        facility = facility,
                        onDeleteClick = { toDelete = facility }
                    )
                }
            }
        }
    }

    // Hộp thoại xác nhận xóa
    toDelete?.let { facility ->
        AlertDialog(
            onDismissRequest = { toDelete = null },
            title = { Text("Xóa cơ sở?") },
            text = {
                Text("Bạn có chắc muốn xóa \"${facility.name}\"? Thao tác này không thể hoàn tác.")
            },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.deleteFacility(facility)
                    toDelete = null
                }) {
                    Text("Xóa")
                }
            },
            dismissButton = {
                TextButton(onClick = { toDelete = null }) {
                    Text("Hủy")
                }
            }
        )
    }
}

@Composable
fun FacilityCard(facility: Facility, onDeleteClick: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(facility.name, style = MaterialTheme.typography.titleMedium)
                Text(facility.address)
                Text("Người đứng đầu: ${facility.headName} (${facility.headPosition})")
                if (facility.businessType.isNotBlank()) {
                    Text("Loại hình: ${facility.businessType}")
                }
            }
            IconButton(onClick = onDeleteClick) {
                Icon(Icons.Filled.Delete, contentDescription = "Xóa cơ sở")
            }
        }
    }
}