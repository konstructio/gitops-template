import React from 'react';
import { Provider } from 'react-redux';
import type { AppProps } from 'next/app';
import Head from 'next/head';
import styled, { ThemeProvider } from 'styled-components';
import { ThemeProvider as ThemeProviderMUI } from '@mui/material';

import theme from '../theme';
import themeMUI from '../theme/muiTheme';
import { wrapper } from '../redux/store';
import Navigation from '../containers/navigation';

import '../styles/globals.css';

const Layout = styled.div`
  background-color: ${({ theme }) => theme.colors.washMe};
  display: flex;
  height: 100%;
`;

export const Header = styled.div`
  background-color: ${({ theme }) => theme.colors.white};
  height: 40px;
  width: calc(100% - 50px);
  border-radius: 0px;
  padding: 12px 24px 12px 24px;
`;

export const Content = styled.div`
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
`;

function App({ Component, ...rest }: AppProps) {
  const { store, props } = wrapper.useWrappedStore(rest);
  return (
    <main id="app">
      <Head>
        <title>Metaphor</title>
        <link rel="shortcut icon" href="/static/jelly.svg" />
      </Head>
      <Provider store={store}>
        <ThemeProviderMUI theme={themeMUI}>
          <ThemeProvider theme={theme}>
            <Layout {...props.pageProps}>
              <Navigation />
              <Content>
                <Header />
                <Component {...props.pageProps} />
              </Content>
            </Layout>
          </ThemeProvider>
        </ThemeProviderMUI>
      </Provider>
    </main>
  );
}

export default App;
