import React, { FunctionComponent, useEffect, useMemo } from 'react';

import Typography from '../../components/typography';
import Card from '../../components/card';
import {
  selectAppData,
  selectIsApiAvailable,
  selectKubernetesData,
  selectMetaphorApiUrl,
  selectVaultData,
} from '../../redux/selectors/metaphor.selector';
import { useAppDispatch, useAppSelector } from '../../redux/store';
import {
  getHealthz,
  getInfoApp,
  getKubernetesData,
  getVaultData,
} from '../../redux/actions/metaphor.action';
import Tag from '../../components/tag';

import { Cards, Container, Header, LearnMoreLink } from './dashboard.styled';

const DOCS_LINK = 'https://docs.kubefirst.io';
const RUNNING_TAG_PROPS = {
  backgroundColor: '#D1FAE5',
  color: '#059669',
};

const ERROR_TAG_PROPS = {
  backgroundColor: '#FCE7F3',
  color: '#BE185D',
};

const Dashboard: FunctionComponent = () => {
  const dispatch = useAppDispatch();

  const metaphorApiUrl = useAppSelector(selectMetaphorApiUrl());
  const isApiAvailable = useAppSelector(selectIsApiAvailable());
  const appData = useAppSelector(selectAppData());
  const kubernetesData = useAppSelector(selectKubernetesData());
  const vaultData = useAppSelector(selectVaultData());

  useEffect(() => {
    const getApiData = async () => {
      await dispatch(getHealthz(metaphorApiUrl)).unwrap();
      await dispatch(getInfoApp(metaphorApiUrl)).unwrap();
      await dispatch(getKubernetesData(metaphorApiUrl)).unwrap();
      await dispatch(getVaultData(metaphorApiUrl)).unwrap();
    };

    if (metaphorApiUrl) {
      getApiData();
    }
  }, [dispatch, metaphorApiUrl]);

  const cardValues = useMemo(
    () => [
      {
        title: 'Metaphor',
        values: [
          {
            key: 'Application name',
            value: appData?.appName,
          },
          {
            key: 'Company name',
            value: appData?.companyName,
          },
          {
            key: 'Chart Version',
            value: appData?.chartVersion,
          },
          {
            key: 'Docket tag',
            value: appData?.dockerTag,
          },
        ],
      },
      {
        title: 'Metaphor API',
        values: [
          {
            key: 'Status',
            value: isApiAvailable ? (
              <Tag {...RUNNING_TAG_PROPS} label="Running" />
            ) : (
              <Tag {...ERROR_TAG_PROPS} label="Unavailable" />
            ),
          },
          {
            key: 'Version',
            value: appData?.chartVersion,
          },
        ],
      },
      {
        title: 'Kubernetes',
        values: [
          {
            key: 'Config one',
            value: kubernetesData?.configOne,
          },
          {
            key: 'Config two',
            value: kubernetesData?.configTwo,
          },
        ],
      },
      {
        title: 'Vault',
        values: [
          {
            key: 'Secret one',
            value: vaultData?.secretOne,
          },
          {
            key: 'Secret two',
            value: vaultData?.secretTwo,
          },
        ],
      },
    ],
    [
      appData?.appName,
      appData?.chartVersion,
      appData?.companyName,
      appData?.dockerTag,
      isApiAvailable,
      kubernetesData?.configOne,
      kubernetesData?.configTwo,
      vaultData?.secretOne,
      vaultData?.secretTwo,
    ],
  );

  return (
    <Container>
      <Header>
        <Typography variant="h6">Welcome to Metaphor</Typography>
        <Typography variant="body2">
          A demo application that demonstrates how an application can be integrated into the
          Kubefirst platform.{' '}
          <LearnMoreLink href={DOCS_LINK} target="_blank">
            Learn more
          </LearnMoreLink>
        </Typography>
      </Header>
      <Cards>
        {cardValues.map((card) => (
          <Card key={card.title} {...card} />
        ))}
      </Cards>
    </Container>
  );
};

export default Dashboard;