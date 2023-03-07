import type { NextApiRequest, NextApiResponse } from 'next';

type Configs = {
  appName: string;
  companyName: string;
  chartVersion: string;
  dockerTag: string;
};

export default function handler(req: NextApiRequest, res: NextApiResponse<Configs>) {
  const { CHART_VERSION = '', DOCKER_TAG = '' } = process.env;

  res.status(200).json({
    appName: 'Metaphor ',
    companyName: 'Kubefirst',
    chartVersion: CHART_VERSION,
    dockerTag: DOCKER_TAG,
  });
}
