package com.example.pccc_app.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface FacilityDao {

    @Insert
    suspend fun insert(facility: Facility): Long

    @Update
    suspend fun update(facility: Facility)

    @Delete
    suspend fun delete(facility: Facility)

    @Query("SELECT * FROM facility ORDER BY name")
    fun getAll(): Flow<List<Facility>>

    @Query("SELECT * FROM facility WHERE id = :id")
    suspend fun getById(id: Long): Facility?
}