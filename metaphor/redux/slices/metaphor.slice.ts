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
  metaphorApiUrl?: string;
  metaphor?: Metaphor;
  metaphorStatus: boolean;
  kubernetesScrets?: Config;
  vaultSecrets?: Config;
}

export const initialState: MetaphorState = {
  metaphorApiUrl: undefined,

  metaphor: undefined,
  metaphorStatus: false,
  kubernetesScrets: undefined,
  vaultSecrets: undefined,
};

const metaphorSlice = createSlice({
  name: 'metaphor',
  initialState,
  reducers: {
    setConfigValues(state, payload) {
      const { metaphorApiUrl } = payload.payload;
      state.metaphorApiUrl = metaphorApiUrl;
    },
  },
  extraReducers(builder) {
    builder.addCase(getHealthz.rejected, (state) => {
      state.metaphorStatus = false;
    });
    builder.addCase(getHealthz.fulfilled, (state) => {
      state.metaphorStatus = true;
    });
    builder.addCase(getInfoApp.fulfilled, (state, action) => {
      state.metaphor = action.payload;
    });
    builder.addCase(getKubernetesData.fulfilled, (state, action) => {
      state.kubernetesScrets = action.payload;
    });
    builder.addCase(getVaultData.fulfilled, (state, action) => {
      state.vaultSecrets = action.payload;
    });
  },
});

export const { setConfigValues } = metaphorSlice.actions;

export default metaphorSlice.reducer;
