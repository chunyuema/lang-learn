enum NetworkError {
    Timeout(u64),
    Refused,
}

enum ConfigError {
    Missing(String),
}

enum AppError {
    Network(NetworkError),
    Config(ConfigError),
}

// Disable this conversion to reproduce E0277 at the question mark below.
#[cfg(not(missing_from))]
impl From<NetworkError> for AppError {
    fn from(error: NetworkError) -> Self {
        Self::Network(error)
    }
}

enum Scenario {
    Success,
    Timeout,
    Refused,
    MissingConfig,
}

fn fetch(scenario: Scenario) -> Result<String, NetworkError> {
    match scenario {
        Scenario::Timeout => Err(NetworkError::Timeout(1500)),
        Scenario::Refused => Err(NetworkError::Refused),
        _ => Ok("response".into()),
    }
}

fn handle(scenario: Scenario) -> Result<String, AppError> {
    if matches!(scenario, Scenario::MissingConfig) {
        return Err(AppError::Config(ConfigError::Missing("app.toml".into())));
    }

    let body = fetch(scenario)?;
    Ok(body)
}

fn report(result: Result<String, AppError>) {
    match result {
        Ok(body) => println!("got {body}"),
        Err(AppError::Network(NetworkError::Timeout(ms))) => println!("retry after {ms} ms"),
        Err(AppError::Network(NetworkError::Refused)) => println!("give up: connection refused"),
        Err(AppError::Config(ConfigError::Missing(file))) => println!("give up: missing {file}"),
    }
}

fn main() {
    report(handle(Scenario::Success));
    report(handle(Scenario::Timeout));
    report(handle(Scenario::Refused));
    report(handle(Scenario::MissingConfig));
}
