import React, { FunctionComponent, ReactNode } from 'react';

import Typography from '../typography';

import { Container, Description, Header, Title, Value, Values } from './card.styled';

export interface CardProps {
  title: string;
  values: Array<{ key: string; value: string | ReactNode }>;
}

const Card: FunctionComponent<CardProps> = ({ title, values }) => {
  return (
    <Container>
      <Header>
        <Typography variant="subtitle2">{title}</Typography>
      </Header>
      <Values>
        {values &&
          values.map(({ key, value }) => (
            <Value key={key}>
              <Title variant="labelMedium">{key}</Title>
              {typeof value === 'string' ? (
                <Description variant="body2">{value}</Description>
              ) : (
                value
              )}
            </Value>
          ))}
      </Values>
    </Container>
  );
};

export default Card;
