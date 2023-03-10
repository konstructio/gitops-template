import styled from 'styled-components';

export const Container = styled.nav<{ collapsible?: boolean }>`
  background-color: ${({ theme }) => theme.colors.moonlessMystery};
  border-radius: 0px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 100vh;
  width: ${({ collapsible }) => (collapsible ? '72px' : '256px')};
`;

export const FooterContainer = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 24px;

  & a {
    text-decoration: none;
  }
`;

export const MenuContainer = styled.div`
  align-items: center;
  display: flex;
  flex-direction: column;
  gap: 10px;

  & a {
    text-decoration: none;
  }
`;

export const MenuItem = styled.div<{ isActive?: boolean; collapsible?: boolean }>`
  align-items: center;
  border-radius: 12px;
  color: #9ea2c6;
  cursor: pointer;
  display: flex;
  gap: 12px;
  height: 24px;
  margin: 0 8px;
  padding: 12px 18px;
  width: 204px;

  &:hover {
    background-color: #252a41;
    color: white;

    svg {
      color: white;
    }
  }

  ${({ isActive }) =>
    isActive &&
    `
      background-color: #252a41;
      color: white;

      svg {
        color: white;
      }
  `}

  ${({ collapsible }) =>
    collapsible &&
    `
    justify-content: center;
    padding: 10px;
    width: 40px;
  `}
`;

export const Title = styled.div<{ collapsible?: boolean }>`
  padding: 24px 16px 0;
  position: relative;
  margin-bottom: 32px;

  ${({ collapsible }) =>
    collapsible &&
    `
    margin-bottom: 8px;
    padding: 12px;
  `}
`;
