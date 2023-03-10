import React, { FunctionComponent } from 'react';

import Navigation from '../../components/navigation';
import { selectConsoleUrl } from '../../redux/selectors/metaphor.selector';
import { useAppSelector } from '../../redux/store';

const NavigationContainer: FunctionComponent = () => {
  const consoleUrl = useAppSelector(selectConsoleUrl());

  return <Navigation consoleUrl={consoleUrl} />;
};

export default NavigationContainer;
