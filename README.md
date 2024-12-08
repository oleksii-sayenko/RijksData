### Build

Create a file named `Config.xcconfig` inside the `RijksData` folder with the following content:

``` 
API_BASE_URL = https:/$()/www.rijksmuseum.nl/api
API_KEY = your-api-key
```

### Next Steps

1. **Navigate to Next/Previous Object Detail**
   - Replace the request manager with a `Repository` object that aggregates the request manager.
   - The `Repository` can cache object numbers for each category, allowing the Detail page to retrieve this data and navigate between objects.

1. **Add Objects to Favorites**
   - The `Repository` object should include a Favorites service.
   - The view model should communicate with the `Repository` to handle favorites.

1. **Avoid Using API models Directly in View Models and Views**
   - Create a separate domain models.
   - For example, if you want to add an `isFavorite` property, this should be done within the view model’s custom model rather than the API model.

1. **Handle Language/Locale Changes**
