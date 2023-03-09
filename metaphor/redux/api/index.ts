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
      query: (baseuRL: string) => `${baseuRL}/healthz`,
    }),
    getInfoApp: builder.query({
      query: (baseuRL: string) => `${baseuRL}/app`,
    }),
    getKubernetesInfo: builder.query({
      query: (baseuRL: string) => `${baseuRL}/kubernetes`,
    }),
    getVaultInfo: builder.query({
      query: (baseuRL: string) => `${baseuRL}/vault`,
    }),
  }),
});

export const { endpoints } = metaphorApi;
