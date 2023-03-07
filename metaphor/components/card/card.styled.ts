import styled from 'styled-components';

import Typography from '../typography';

export const Container = styled.div`
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;

  &:last-child {
    border-bottom: none;
  }
`;

export const Header = styled.div`
  color: #334155;
  margin-bottom: 14px;
`;

export const Values = styled.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
`;

export const Value = styled.div`
  align-items: center;
  display: flex;
  flex-direction: row;
  gap: 40px;
`;

export const Title = styled(Typography)`
  color: #71717a;
  width: 134px;
`;

export const Description = styled(Typography)`
  color: ${({ theme }) => theme.colors.volcanicSand};
`;
