# Solution description

## Solution architecture

Application can be devided into 4 layers:

### 1. View layer
consists of view controller and cells. They are responsible for displaying data and handling user input only.
### 2. ViewModel layer
consists of whole view's ViewModel (aka `CurrenciesViewModelImpl`) and cell's ViewModel (aka `CurrencyCellViewModelImpl`). While cell's view model is responsible for preparing data to display on a single cell and handling user input on it, view's view model is responsible for coordinating between cells' view model, business logic and data loading.
### 3. Business logic
consists of 2 components: `AmountCalculator` and `CurrencyInfoProvider`. The first one calculates values for each currency based on latest user input. The second one gets additional info about currencies (such as name and flag) with a help of Foundation's `Locale` class.
### 4. Networking
consists of 2 classes: `AlamofireWrapper` and `RatesRequestor`. This layer is responsible for getting exchange rates information with a given refresh rate and handling errors.

## Refresh rules
Refresh is usually happened around 1 second after previous request is complete. GCD can slightly move forward this event to optimize computing resources. We don't schedule a new request unless previous one is completed to avoid duplicating requests on high-latency networks. Scheduling happens with a background QoS because average user pays much more attention to animation smothness and app's responsiveness than to a refesh rate.
Once user selects a currency for input, it is being used for fetch as a base currency to minimize CPU load and improve calculation accuracy.
If network request fails due to lack of connection,  refreshing is paused unless connection isn't available again. In case of any other error new request is scheduled normally. In case we didn't receive updates due to errors for a long time (intially configured for 10 mins), local data is invalidated.

## Calculations
Calculations are based on 3 input values: rates data received from server, last user input and currency for which we're calculating. To reduce CPU load, user input converted to the base currency is store and used in all other calculations. Calculator class is thread-safe. It is needed to access it from different queues: main queue to set user input, `RatesRequestor`'s private queue to set currencies data, cell view models' private queues for preparing ui values.

## Getting currency info
Because no API for currency info was provided, application uses information provided by `Locale` class. App builds a Dictionary of Locales by currency codes. Because different countries can use same currency (for example, New Zeland and Cook Islands) we need to choose between several locales with same currency code. We select locale where country and currency codes match each other the best. For example, Cook Islands (CK) and New Zeland (NZ) both use New Zeland Dollar (NZD), we choose New Zeeland because it NZ matches NZD.
After that, country code is used to get unicode flag emoji and locale along with number formatter is used to get currency name. Exception is made for "EUR" code because it's unique case when there is no primary country for Euro.
