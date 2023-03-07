import React, { FunctionComponent } from 'react';

import Typography from '../typography';

import { Container } from './tag.styled';

export interface TagProps {
  backgroundColor: string;
  color: string;
  label: string;
  onClick?: () => void;
}

const Tag: FunctionComponent<TagProps> = ({ backgroundColor, color, label, onClick }) => (
  <Container backgroundColor={backgroundColor} color={color} onClick={onClick}>
    <Typography variant="body3">{label}</Typography>
  </Container>
);

export default Tag;
