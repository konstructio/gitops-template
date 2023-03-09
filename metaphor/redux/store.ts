import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import { Action, configureStore, ThunkAction } from '@reduxjs/toolkit';
import { createWrapper } from 'next-redux-wrapper';

import { metaphorApi } from './api';
import metaphorSlice from './slices/metaphor.slice';

export const makeStore = () =>
  configureStore({
    reducer: {
      [metaphorApi.reducerPath]: metaphorApi.reducer,
      metaphor: metaphorSlice,
    },
    middleware: (gDM) => gDM().concat(metaphorApi.middleware),
  });

export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

export type AppStore = ReturnType<typeof makeStore>;
export type RootState = ReturnType<AppStore['getState']>;
export type AppDispatch = AppStore['dispatch'];
export type AppThunk<ReturnType = void> = ThunkAction<
  ReturnType,
  RootState,
  unknown,
  Action<string>
>;

export const wrapper = createWrapper<AppStore>(makeStore);
