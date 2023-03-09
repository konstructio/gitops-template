import React, { FunctionComponent, useEffect } from 'react';

import { useAppDispatch } from '../redux/store';
import { setConfigValues } from '../redux/slices/metaphor.slice';
import Dashboard from '../containers/dashboard';

interface HomeProps {
  metaphorApiUrl: string;
}

const Home: FunctionComponent<HomeProps> = ({ metaphorApiUrl }) => {
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(setConfigValues({ metaphorApiUrl }));
  }, [dispatch, metaphorApiUrl]);

  return <Dashboard />;
};

export async function getServerSideProps() {
  const { METAPHOR_API_URL = '' } = process.env;

  return {
    props: {
      metaphorApiUrl: METAPHOR_API_URL,
    },
  };
}

export default Home;
