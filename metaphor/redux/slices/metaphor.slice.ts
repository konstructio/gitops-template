/* eslint-disable @typescript-eslint/no-explicit-any */
import { createSlice } from '@reduxjs/toolkit';

import {
  getHealthz,
  getInfoApp,
  getKubernetesData,
  getVaultData,
} from '../actions/metaphor.action';

export interface Metaphor {
  appName: string;
  companyName: string;
  chartVersion: string;
  dockerTag: string;
}

export interface Config {
  [key: string]: string;
}

export interface MetaphorState {
  consoleUrl?: string;
  metaphor?: Metaphor;
  metaphorStatus: boolean;
  kubernetesScrets?: Config;
  vaultSecrets?: Config;
  isLoading: boolean;
}

export const initialState: MetaphorState = {
  consoleUrl: undefined,
  metaphor: undefined,
  metaphorStatus: false,
  kubernetesScrets: undefined,
  vaultSecrets: undefined,
  isLoading: true,
};

const metaphorSlice = createSlice({
  name: 'metaphor',
  initialState,
  reducers: {
    setConfigValues(state, payload) {
      const { consoleUrl } = payload.payload;
      state.consoleUrl = consoleUrl;
    },
  },
  extraReducers(builder) {
    builder.addCase(getHealthz.pending, (state) => {
      state.isLoading = true;
    });
    builder.addCase(getHealthz.rejected, (state) => {
      state.metaphorStatus = false;
      state.isLoading = false;
    });
    builder.addCase(getHealthz.fulfilled, (state) => {
      state.metaphorStatus = true;
      state.isLoading = false;
    });
    builder.addCase(getInfoApp.pending, (state) => {
      state.isLoading = true;
    });
    builder.addCase(getInfoApp.rejected, (state) => {
      state.isLoading = false;
    });
    builder.addCase(getInfoApp.fulfilled, (state, action) => {
      state.metaphor = action.payload;
      state.isLoading = false;
    });
    builder.addCase(getKubernetesData.pending, (state) => {
      state.isLoading = true;
    });
    builder.addCase(getKubernetesData.rejected, (state) => {
      state.isLoading = false;
    });
    builder.addCase(getKubernetesData.fulfilled, (state, action) => {
      state.kubernetesScrets = action.payload;
      state.isLoading = false;
    });
    builder.addCase(getVaultData.fulfilled, (state, action) => {
      state.vaultSecrets = action.payload;
      state.isLoading = false;
    });
  },
});

export const { setConfigValues } = metaphorSlice.actions;

export default metaphorSlice.reducer;
