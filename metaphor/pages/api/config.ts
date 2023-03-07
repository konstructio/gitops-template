import type { NextApiRequest, NextApiResponse } from 'next';

type Configs = {
  [key: string]: string;
};

export default function handler(req: NextApiRequest, res: NextApiResponse<Configs>) {
  const {
    METAPHOR_API_URL = '',
    CHART_VERSION = '',
    DOCKER_TAG = '',
    SECRET_ONE = '',
    SECRET_TWO = '',
    CONFIG_ONE = '',
    CONFIG_TWO = '',
  } = process.env;

  res.status(200).json({
    METAPHOR_API_URL,
    CHART_VERSION,
    DOCKER_TAG,
    SECRET_ONE,
    SECRET_TWO,
    CONFIG_ONE,
    CONFIG_TWO,
  });
}
