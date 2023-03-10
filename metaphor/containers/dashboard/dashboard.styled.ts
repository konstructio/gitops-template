import styled from 'styled-components';
import Link from 'next/link';

import Typography from '../../components/typography';

export const Cards = styled.div`
  background-color: ${({ theme }) => theme.colors.white};
  border: 1px solid #e2e8f0;
  border-radius: 12px;
`;

export const Container = styled.div`
  height: calc(100vh - 80px);
  overflow: auto;
  padding: 40px;
  margin: 0 auto;
  max-width: 1192px;
`;

export const Header = styled.div`
  color: ${({ theme }) => theme.colors.volcanicSand};
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 40px;
`;

export const LearnMoreLink = styled(Link)`
  color: ${({ theme }) => theme.colors.primary};
  text-decoration: none;
`;

export const Title = styled(Typography)`
  align-items: center;
  display: flex;
  gap: 20px;

  > div {
    align-items: center;
    display: flex;
    height: 16px;
    text-transform: uppercase;
  }
`;
