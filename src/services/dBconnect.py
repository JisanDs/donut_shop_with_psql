from psycopg_pool import ConnectionPool
from dataclasses import dataclass


@dataclass
class DBConnect:
    """
    This class is use to connect with database.
    Class take 2 args:
        user: username of the database.
        passwd: password of the database.

    This class have also 3 function.
    1. connect_db()
    2. get_conn()
    3. close_conn()
    """
    user: str
    passwd: str

    def connect_db(self):
        """This is initial to use this setup connection. Use this first."""

        self.CONN_INFO = f"dbname=donut_shop user={self.user} password={self.passwd} host=127.0.0.1 port=5432"
        self._pool = ConnectionPool(
            conninfo=self.CONN_INFO,
            min_size=1,
            max_size=5,
            kwargs={"autocommit": True}
        )

    def get_conn(self):
        """This function return connection from the connect_db() function."""
        return self._pool.connection()

    def close_conn(self):
        """This function use to close connection."""
        if self._pool:
            self._pool.close()
