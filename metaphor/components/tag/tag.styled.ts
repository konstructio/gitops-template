import styled from 'styled-components';

export const Container = styled.div<{
  backgroundColor: string;
  color: string;
}>`
  background-color: ${({ backgroundColor }) => backgroundColor};
  border-radius: 4px;
  color: ${({ color }) => color};
  padding: 4px;
`;
