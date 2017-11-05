module.exports = class {
    onCreate() {
        this.state = {
            authToken: null,
            error: null
            };
    }

    login(event) {
        event.preventDefault();

        const url = 'http://127.0.0.1:4000/sessions';

        const login = this.getEl('login').value
        const password = this.getEl('password').value

        const data = `{"username": "${login}", "password": "${password}"}`

        const headers = new Headers()
        headers.set('Content-Type', 'application/json')
        const init = {
            method: 'POST',
            headers: headers,
            body: data
        };
        fetch(url, init)
            .then( response => {
                if(!response.ok) {
                    console.log("error")
                    this.state.error = "Authentication failed";
                }
                return response.json()
            })
            .then( userProfile => {
                this.state.authToken = userProfile.auth_token;
                if(this.state.authToken === undefined) {
                    this.state.error = "Authentication failed";
                } else {
                    this.state.error = null;
                }
            })
            .catch( error => this.state.error = error );
      }
};