const jsonServer = require('json-server')
const server = jsonServer.create()
const router = jsonServer.router('db.json')

// Set default middlewares (logger, static, cors and no-cache)
const middlewares = jsonServer.defaults()
server.use(middlewares)

server.use(jsonServer.bodyParser)
server.use((req, res, next) => {
    if (isLoginRequest(req)) {
        if (areTestUserCredentials(req.body)) {
            res.jsonp(userAuthenticationDetails)
        } else {
            res.sendStatus(401)
        }
    } else {
        next()
    }
})

const userAuthenticationDetails = {
    "auth_token": "eyJ1c2VyX2F1dGhlbnRpY2F0aW9uX2lkIjoxNn0:1dQERV:gMlrZm2vzmC6lRtSqOx0HTUyGGU",
    "big_photo": null,
    "bio": "",
    "color": "#b5f04f",
    "email": "test@user.com",
    "full_name": "test-user",
    "full_name_display": "TEST USER",
    "gravatar_id": "1ec29e4d0732b571e9a975e258a7e9b5",
    "id": 16,
    "is_active": true,
    "lang": "",
    "max_memberships_private_projects": null,
    "max_memberships_public_projects": null,
    "max_private_projects": null,
    "max_public_projects": null,
    "photo": null,
    "roles": [
        "Front"
    ],
    "theme": "",
    "timezone": "",
    "total_private_projects": 0,
    "total_public_projects": 0,
    "username": "user"
}



function isLoginRequest(req) {
    console.log("isLoginRequest")
    return req.method === 'POST' && req.url == '/api/v1/auth'
}

function areTestUserCredentials(credentials) {
    console.log("areTestUserCredentials", credentials)
    return credentials.username == 'user' && credentials.password == 'pass'
}


// Use default router
server.use(router)
server.listen(3000, () => {
    console.log('JSON Server is running and listens to port 3000')
})