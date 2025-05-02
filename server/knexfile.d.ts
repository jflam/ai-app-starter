declare const config: {
  [key: string]: {
    client: string;
    connection: {
      filename?: string;
      host?: string;
      user?: string;
      password?: string;
      database?: string;
      ssl?: boolean | { rejectUnauthorized: boolean };
    };
    migrations: {
      tableName: string;
      directory: string;
    };
    seeds: {
      directory: string;
    };
    useNullAsDefault?: boolean;
  };
};

export = config;
