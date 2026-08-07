import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";

const API_URL = import.meta.env.VITE_API_URL || "/api/items";

// Async thunks
export const fetchItems = createAsyncThunk("groceries/fetch", async () => {
  const res = await axios.get(API_URL);
  return res.data;
});

export const addItemAsync = createAsyncThunk("groceries/add", async (item) => {
  const res = await axios.post(API_URL, { item });
  return res.data;
});

export const removeItemAsync = createAsyncThunk(
  "groceries/remove",
  async (item) => {
    const res = await axios.delete(`${API_URL}/${item}`);
    return res.data;
  }
);

export const clearAllAsync = createAsyncThunk(
  "groceries/clearAll",
  async () => {
    const res = await axios.delete(API_URL);
    return res.data;
  }
);

const grocerySlice = createSlice({
  name: "groceries",
  initialState: {
    items: [],
    filter: "",
    status: "idle",
    error: null,
  },
  reducers: {
    setFilter: (state, action) => {
      state.filter = action.payload;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchItems.pending, (state) => {
        state.status = "loading";
      })
      .addCase(fetchItems.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.items = action.payload;
      })
      .addCase(fetchItems.rejected, (state, action) => {
        state.status = "failed";
        state.error = action.error.message;
      })
      .addCase(addItemAsync.pending, (state) => {
        state.status = "loading";
      })
      .addCase(addItemAsync.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.items = action.payload;
      })
      .addCase(addItemAsync.rejected, (state, action) => {
        state.status = "failed";
        state.error = action.error.message;
      })
      .addCase(removeItemAsync.pending, (state) => {
        state.status = "loading";
      })
      .addCase(removeItemAsync.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.items = action.payload;
      })
      .addCase(removeItemAsync.rejected, (state, action) => {
        state.status = "failed";
        state.error = action.error.message;
      })
      .addCase(clearAllAsync.pending, (state) => {
        state.status = "loading";
      })
      .addCase(clearAllAsync.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.items = action.payload;
      })
      .addCase(clearAllAsync.rejected, (state, action) => {
        state.status = "failed";
        state.error = action.error.message;
      });
  },
});

export const { setFilter, clearError } = grocerySlice.actions;
export default grocerySlice.reducer;
