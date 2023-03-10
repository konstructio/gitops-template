import React, { FunctionComponent, useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
// import { useRouter } from 'next/router';
import Link from 'next/link';

import Typography from '../typography/';
import Help from '../../assets/help.svg';
import Slack from '../../assets/slack.svg';
import LinkIcon from '../../assets/link.svg';

import { Container, FooterContainer, MenuContainer, MenuItem, Title } from './navigation.styled';

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
  consoleUrl: string;
  collapsible?: boolean;
}

const Navigation: FunctionComponent<NavigationProps> = ({ consoleUrl, collapsible }) => {
  const [domLoaded, setDomLoaded] = useState(false);

  const ROUTES = useMemo(
    () => [
      {
        icon: LinkIcon,
        path: consoleUrl,
        title: 'kubefirst console',
        target: '_blank',
      },
    ],
    [consoleUrl],
  );

  useEffect(() => {
    setDomLoaded(true);
  }, []);

  return (
    <Container collapsible={collapsible}>
      <div>
        <Title collapsible={collapsible}>
          <Image alt="metaphor-image" src={'/static/metaphor.svg'} height={40} width={208} />
          <Typography
            variant="labelSmall"
            color="#ABADC6"
            sx={{ position: 'absolute', left: 65, bottom: -10 }}
          >
            V2.0.0
          </Typography>
        </Title>
        {domLoaded && (
          <MenuContainer>
            {ROUTES.map(({ icon, path, title, target }) => (
              <Link href={path} key={path} target={target}>
                <MenuItem collapsible={collapsible}>
                  <Image alt={title} src={icon} height={20} width={20} />
                  {!collapsible && <Typography variant="body1">{title}</Typography>}
                </MenuItem>
              </Link>
            ))}
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
