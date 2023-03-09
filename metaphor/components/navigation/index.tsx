import React, { FunctionComponent, useEffect, useState } from 'react';
import Image from 'next/image';
// import { useRouter } from 'next/router';
import Link from 'next/link';

import Typography from '../typography/';
import Help from '../../assets/help.svg';
import Slack from '../../assets/slack.svg';

import { Container, FooterContainer, MenuContainer, MenuItem, Title } from './navigation.styled';

// const ROUTES = [];

const FOOTER_ITEMS = [
  {
    icon: Help,
    path: 'https://docs.kubefirst.io',
    title: 'Help Documentation',
  },
  {
    icon: Slack,
    path: 'https://bit.ly/kubefirst-slack',
    title: 'Slack',
  },
];

export interface NavigationProps {
  collapsible?: boolean;
}

const Navigation: FunctionComponent<NavigationProps> = ({ collapsible }) => {
  const [domLoaded, setDomLoaded] = useState(false);
  // const { asPath } = useRouter();
  const kubefirstVersion = '0.1.0';

  // const isActive = (route: string) => {
  //   if (typeof window !== 'undefined') {
  //     const linkPathname = new URL(route as string, window?.location?.href).pathname;

  //     // Using URL().pathname to get rid of query and hash
  //     const activePathname = new URL(asPath, window?.location?.href).pathname;

  //     return linkPathname === activePathname;
  //   }
  // };

  useEffect(() => {
    setDomLoaded(true);
  }, []);

  return (
    <Container collapsible={collapsible}>
      <div>
        <Title collapsible={collapsible}>
          <Typography variant="h6" color="secondary">
            Metaphor
          </Typography>
          {kubefirstVersion && (
            <Typography
              variant="labelSmall"
              color="#ABADC6"
              sx={{ position: 'absolute', left: 16, bottom: -20 }}
            >
              {`V${kubefirstVersion}`}
            </Typography>
          )}
        </Title>
        {domLoaded && (
          <MenuContainer>
            {/* {ROUTES.map(({ icon, path, title }) => (
              <Link href={path} key={path}>
                <MenuItem isActive={isActive(path)} collapsible={collapsible}>
                  {icon}
                  {!collapsible && <Typography variant="body1">{title}</Typography>}
                </MenuItem>
              </Link>
            ))} */}
          </MenuContainer>
        )}
      </div>
      <FooterContainer>
        {FOOTER_ITEMS.map(({ icon, path, title }) => (
          <Link href={path} key={path} target="_blank">
            <MenuItem collapsible={collapsible}>
              <Image src={icon} height={20} width={20} alt={title} />
              {!collapsible && <Typography variant="body1">{title}</Typography>}
            </MenuItem>
          </Link>
        ))}
      </FooterContainer>
    </Container>
  );
};

export default Navigation;
