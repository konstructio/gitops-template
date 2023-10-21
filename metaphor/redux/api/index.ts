import { createApi } from '@reduxjs/toolkit/dist/query/react';
import { fetchBaseQuery } from '@reduxjs/toolkit/dist/query';
import { HYDRATE } from 'next-redux-wrapper';

export const metaphorApi = createApi({
  baseQuery: fetchBaseQuery({
    baseUrl: '',
  }),
  extractRehydrationInfo(action, { reducerPath }) {
    if (action.type === HYDRATE) {
      return action.payload[reducerPath];
    }
  },
  tagTypes: [],
  endpoints: (builder) => ({
    healthz: builder.query({
      query: () => `api/healthz`,
    }),
    getInfoApp: builder.query({
      query: () => `api/app`,
    }),
    getKubernetesInfo: builder.query({
      query: () => `api/kubernetes`,
    }),
    getVaultInfo: builder.query({
      query: () => `api/vault`,
    }),
  }),
});

export const { endpoints } = metaphorApi;
