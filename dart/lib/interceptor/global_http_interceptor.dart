part of security_monkey;

class GlobalHttpInterceptors {

    static setUp(Injector inj) => new GlobalHttpInterceptors(inj)..addGlobalAlertInterceptor();

    Injector inj;
    GlobalHttpInterceptors(this.inj);

    addGlobalAlertInterceptor() => inj.get(HttpInterceptors)..add(_buildGlobalAlertInterceptor());

    _buildGlobalAlertInterceptor() => new HttpInterceptor()

            // ERROR
            ..responseError = (error) {
                final messages = inj.get(Messages);

                if (error is HttpResponse && error.status == 401 && error.headers('content-type') == 'application/json') {
                    HttpResponse response = error;
                    try {
                        var data = JSON.decode(response.data);
                        var authdata = data['auth'];
                        if(authdata.containsKey('change_password')){
                            // dummy parameter.. can be adapted to something of more use...
                            messages.password_expired(data['auth']['url']);
                        }else {
                            messages.auth_url_change(data['auth']['url']);
                        }
                    } catch (e) {
                        print("Exception Extracting Auth URL from response <$response>");
                    }
                } else if (error is HttpResponse && error.status == 0) {
                    messages.alert(_globalAlertMessage("API Server is not reachable."));
                } else {
                    messages.alert(_globalAlertMessage(error));
                }
                return new Future.error(error);
            }

            // OK
            ..response = (HttpResponse response) {
                if (response.headers('content-type') != 'application/json') {
                    return response;
                }

                Map data;
                try {
                    data = JSON.decode(response.data);
                } catch (e) {
                    print("Invalid JSON Returned: ${response.data}");
                    return response;
                }

                try {
                    var user = data['auth']['user'];
                    final messages = inj.get(Messages);
                    messages.username_change(data['auth']['user']);
                    if(data['auth']["roles"] != null){
                      messages.roles_change(data['auth']['roles']);
                    }
                } catch (e) {
                    print("No auth-user section in JSON blob. $e");
                    // ${response.data}
                }

                return response;
            };

    _globalAlertMessage(error) {
        return "Error loading resource from API. Error: <$error>";
    }
}
