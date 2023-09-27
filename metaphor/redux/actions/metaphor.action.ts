/* eslint-disable @typescript-eslint/no-explicit-any */
import { createAsyncThunk } from '@reduxjs/toolkit';

import { endpoints } from '../api/index';

const { healthz, getInfoApp: getInfoApi, getKubernetesInfo, getVaultInfo } = endpoints;

export const getHealthz = createAsyncThunk<any>('metaphor/healthz', async (_, { dispatch }) => {
  const response = await healthz.initiate({});
  return dispatch(response).unwrap();
});

export const getInfoApp = createAsyncThunk<any>('metaphor/app', async (_, { dispatch }) => {
  const response = await getInfoApi.initiate({});
  return dispatch(response).unwrap();
});

export const getKubernetesData = createAsyncThunk<any>(
  'metaphor/kubernetes',
  async (_, { dispatch }) => {
    const response = await getKubernetesInfo.initiate({});
    return dispatch(response).unwrap();
  },
);

export const getVaultData = createAsyncThunk<any>('metaphor/vault', async (_, { dispatch }) => {
  const response = await getVaultInfo.initiate({});
  return dispatch(response).unwrap();
});
