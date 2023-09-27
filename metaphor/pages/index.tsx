import React, { FunctionComponent, useEffect } from 'react';

import { useAppDispatch } from '../redux/store';
import { setConfigValues } from '../redux/slices/metaphor.slice';
import Dashboard from '../containers/dashboard';

interface HomeProps {
  consoleUrl: string;
}

const Home: FunctionComponent<HomeProps> = ({ consoleUrl }) => {
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(setConfigValues({ consoleUrl }));
  }, [consoleUrl, dispatch]);

  return <Dashboard />;
};

export async function getServerSideProps() {
  const { CONSOLE_URL = '' } = process.env;

  return {
    props: {
      consoleUrl: CONSOLE_URL,
    },
  };
}

export default Home;
