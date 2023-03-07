/* eslint-disable @typescript-eslint/no-explicit-any */
import { createAsyncThunk } from '@reduxjs/toolkit';

import { endpoints } from '../api/index';

const { healthz, getInfoApp: getInfoApi, getKubernetesInfo, getVaultInfo } = endpoints;

export const getHealthz = createAsyncThunk<any, string>(
  'metaphor/healthz',
  async (param, { dispatch }) => {
    const response = await healthz.initiate(param);
    return dispatch(response).unwrap();
  },
);

export const getInfoApp = createAsyncThunk<any, string>(
  'metaphor/app',
  async (param, { dispatch }) => {
    const response = await getInfoApi.initiate(param);
    return dispatch(response).unwrap();
  },
);

export const getKubernetesData = createAsyncThunk<any, string>(
  'metaphor/kubernetes',
  async (param, { dispatch }) => {
    const response = await getKubernetesInfo.initiate(param);
    return dispatch(response).unwrap();
  },
);

export const getVaultData = createAsyncThunk<any, string>(
  'metaphor/vault',
  async (param, { dispatch }) => {
    const response = await getVaultInfo.initiate(param);
    return dispatch(response).unwrap();
  },
);
