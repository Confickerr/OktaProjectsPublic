
import asyncio
from okta.client import Client as OktaClient


config = {
    'orgUrl': '[URL]',
    'token': '[TOKEN]'
}


usersArray = ['test.adjunct@email.edu', 'test.faculty@email.edu', 'test.staff@email.edu',
              'test.student@email.edu', 'test.motivis.faculty@email.edu', 'test.employee@email.edu']


async def main():
    client = OktaClient(config)
    users, resp, err = await client.list_users()
    while True:
        for user in users:
            print(user.profile.login, '|', user.created, '|', user.last_login)  # Add more properties here.
        if resp.has_next():
            users, err = await resp.next()
        else:
            break

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
