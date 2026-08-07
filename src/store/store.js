import { configureStore, combineReducers } from "@reduxjs/toolkit";
import storage from "redux-persist/lib/storage";
import { persistStore, persistReducer } from "redux-persist";
import groceryReducer from "./grocerySlice";

const rootReducer = combineReducers({
  groceries: groceryReducer,
})

const persistConfig = {
  key: 'root',
  storage,
  whitelist: ['groceries'], // what to persist
}

const persistedReducer = persistReducer(persistConfig, rootReducer);


export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefault) =>
    getDefault({
      serializableCheck: false,
    }),
});

export const persistor = persistStore(store);