import React, { FunctionComponent, useEffect } from 'react';

import { useAppDispatch } from '../redux/store';
import { setConfigValues } from '../redux/slices/metaphor.slice';
import Dashboard from '../containers/dashboard';

interface HomeProps {
  consoleUrl: string;
  metaphorApiUrl: string;
}

const Home: FunctionComponent<HomeProps> = ({ consoleUrl, metaphorApiUrl }) => {
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(setConfigValues({ consoleUrl, metaphorApiUrl }));
  }, [consoleUrl, dispatch, metaphorApiUrl]);

  return <Dashboard />;
};

export async function getServerSideProps() {
  const { METAPHOR_API_URL = '', CONSOLE_URL = '' } = process.env;

  return {
    props: {
      consoleUrl: CONSOLE_URL,
      metaphorApiUrl: METAPHOR_API_URL,
    },
  };
}

export default Home;
