import { createSelector } from '@reduxjs/toolkit';

import { Config, Metaphor, MetaphorState } from '../slices/metaphor.slice';
import { RootState } from '../store';

const metaphorSelector = (state: RootState): MetaphorState => state.metaphor;

export const selectIsApiAvailable = () =>
  createSelector(metaphorSelector, ({ metaphorStatus }) => !!metaphorStatus);

export const selectAppData = () =>
  createSelector(metaphorSelector, ({ metaphor }) => metaphor || ({} as Metaphor));

export const selectKubernetesData = () =>
  createSelector(metaphorSelector, ({ kubernetesScrets }) => kubernetesScrets || ({} as Config));

export const selectVaultData = () =>
  createSelector(metaphorSelector, ({ vaultSecrets }) => vaultSecrets || ({} as Config));

export const selectConsoleUrl = () =>
  createSelector(metaphorSelector, ({ consoleUrl }) => consoleUrl || '');

export const selectIsLoading = () =>
  createSelector(metaphorSelector, ({ isLoading }) => !!isLoading);
