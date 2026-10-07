package com.example.pccc_app.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.pccc_app.data.Facility

private val BUSINESS_TYPES = listOf(
    "Sản xuất",
    "Kinh doanh, thương mại",
    "Dịch vụ lưu trú",
    "Giáo dục",
    "Y tế",
    "Chung cư, nhà ở",
    "Kho bãi",
    "Khác"
)

@Composable
fun FacilityFormScreen(
    onDone: () -> Unit,
    viewModel: FacilityViewModel = viewModel()
) {
    var step by rememberSaveable { mutableIntStateOf(1) }
    var showErrors by rememberSaveable { mutableStateOf(false) }

    // Bước 1
    var name by rememberSaveable { mutableStateOf("") }
    var address by rememberSaveable { mutableStateOf("") }
    var businessType by rememberSaveable { mutableStateOf("") }
    var areaText by rememberSaveable { mutableStateOf("") }
    var floorsText by rememberSaveable { mutableStateOf("") }

    // Bước 2
    var headName by rememberSaveable { mutableStateOf("") }
    var headPosition by rememberSaveable { mutableStateOf("") }
    var phone by rememberSaveable { mutableStateOf("") }

    val step1Valid = name.isNotBlank() && address.isNotBlank()
    val step2Valid = headName.isNotBlank() && headPosition.isNotBlank()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Text("Thêm cơ sở", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(4.dp))
        Text(
            if (step == 1) "Bước 1/2: Thông tin cơ sở" else "Bước 2/2: Người đứng đầu",
            style = MaterialTheme.typography.bodyMedium
        )
        Spacer(Modifier.height(8.dp))
        LinearProgressIndicator(
            progress = { step / 2f },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(16.dp))

        if (step == 1) {
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Tên cơ sở *") },
                isError = showErrors && name.isBlank(),
                supportingText = { if (showErrors && name.isBlank()) Text("Bắt buộc nhập") },
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = address,
                onValueChange = { address = it },
                label = { Text("Địa chỉ *") },
                isError = showErrors && address.isBlank(),
                supportingText = { if (showErrors && address.isBlank()) Text("Bắt buộc nhập") },
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(8.dp))
            BusinessTypeDropdown(
                selected = businessType,
                onSelected = { businessType = it }
            )
            Spacer(Modifier.height(8.dp))

            OutlinedTextField(
                value = areaText,
                onValueChange = { areaText = it },
                label = { Text("Diện tích (m²)") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = floorsText,
                onValueChange = { floorsText = it },
                label = { Text("Số tầng") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
        } else {
            OutlinedTextField(
                value = headName,
                onValueChange = { headName = it },
                label = { Text("Họ tên người đứng đầu *") },
                isError = showErrors && headName.isBlank(),
                supportingText = { if (showErrors && headName.isBlank()) Text("Bắt buộc nhập") },
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = headPosition,
                onValueChange = { headPosition = it },
                label = { Text("Chức vụ *") },
                isError = showErrors && headPosition.isBlank(),
                supportingText = { if (showErrors && headPosition.isBlank()) Text("Bắt buộc nhập") },
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = phone,
                onValueChange = { phone = it },
                label = { Text("Số điện thoại") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                modifier = Modifier.fillMaxWidth()
            )
        }

        Spacer(Modifier.height(24.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            if (step == 1) {
                OutlinedButton(onClick = onDone, modifier = Modifier.weight(1f)) {
                    Text("Hủy")
                }
                Button(
                    onClick = {
                        if (step1Valid) {
                            step = 2
                            showErrors = false
                        } else {
                            showErrors = true
                        }
                    },
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Tiếp tục")
                }
            } else {
                OutlinedButton(
                    onClick = {
                        step = 1
                        showErrors = false
                    },
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Quay lại")
                }
                Button(
                    onClick = {
                        if (step2Valid) {
                            viewModel.addFacility(
                                Facility(
                                    name = name.trim(),
                                    address = address.trim(),
                                    headName = headName.trim(),
                                    headPosition = headPosition.trim(),
                                    phone = phone.trim(),
                                    businessType = businessType,
                                    areaM2 = areaText.replace(',', '.').toDoubleOrNull(),
                                    floors = floorsText.toIntOrNull()
                                )
                            )
                            onDone()
                        } else {
                            showErrors = true
                        }
                    },
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Lưu")
                }
            }
        }
    }
}

// Ô chọn loại hình: bấm vào để mở danh sách
@Composable
private fun BusinessTypeDropdown(
    selected: String,
    onSelected: (String) -> Unit
) {
    var expanded by rememberSaveable { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxWidth()) {
        OutlinedButton(
            onClick = { expanded = true },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(if (selected.isBlank()) "Chọn loại hình hoạt động" else selected)
        }
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            BUSINESS_TYPES.forEach { type ->
                DropdownMenuItem(
                    text = { Text(type) },
                    onClick = {
                        onSelected(type)
                        expanded = false
                    }
                )
            }
        }
    }
}