# Pack Buddy

<p align="left">
  <img src="https://github.com/jonathanvieri/Pack-Buddy/blob/main/images/applogo.png" width="150" height="150" >
</p>

<p>
  Pack Buddy is a packing organization app designed to help users create, manage, and track packing lists for trips. 
  It simplifies trip preparation by organizing items into categories, tracking completion, and offering template suggestions to speed up the packing process.
</p>

<p>
  Pack Buddy ensures your packing process is organized and efficient, making it ideal for frequent travelers or anyone looking to stay prepared and avoid forgetting essential items.
</p>


## Screenshots
<p align="left">
  <img src="https://github.com/jonathanvieri/Pack-Buddy/blob/main/images/packing-screen.png" height="400">
  &emsp;&emsp;
  <img src="https://github.com/jonathanvieri/Pack-Buddy/blob/main/images/add-packing-screen.png" height="400">
</p>
<br>
<p align="left">
  <img src="https://github.com/jonathanvieri/Pack-Buddy/blob/main/images/items-screen.png" height="400">
  &emsp;&emsp;
  <img src="https://github.com/jonathanvieri/Pack-Buddy/blob/main/images/add-category-screen.png" height="400">
</p>


## Features
- **Create Custom Packing Lists**: Easily create new packing lists for each trip by entering details like the trip name, location, and dates.
- **Category Management**: Select from pre-made templates or create your own custom categories to suit your packing needs.
- **Track Packing Progress**: Visual progress bars help you track how much of your packing is complete as you check off items.
- **Search Functionality**: Quickly find specific trips by typing into the built-in search bar.
- **Manage Items within Categories**: Easily add, edit, or delete items within each category for organized packing.


## Technical Overview
 Built entirely using native Swift frameworks and no third-party libraries.
- **UIKit**: Used for building the user interface.
- **MVVM (Model-View-ViewModel)**: Applied for a clean separation of concerns, making the app modular and easier to maintain.
- **Core Data**: Used for persistent storage of packing lists, categories, and items, with support for offline access and data relationships.
- **Core Animation**: Utilized via UIView.animate & UIView.transition to create smooth transitions and animations.
- **UIGestureRecognizer**: Implements gestures like long-press for editing and deleting, and UITableView’s built-in swipe actions for item deletion.
- **UISearchBar**: Provides a search feature to quickly filter and find specific packing lists.
- **Custom Views**: Extensively uses custom UIKit views for specialized components like progress bars and custom table view cells.
- **XCTest**: Unit testing using XCTest framework.


## Usage
1. **Create a New Packing List**: Open the app and tap the "+" button to create a new packing list. Fill in the trip name, location, and trip dates.
2. **Add Categories**: Choose from pre-made category templates (e.g., Clothing, Electronics, Toiletries) or create your own custom categories for better packing organization.
3. **Track Progress**: As you pack items, check them off, and the visual progress bar will update to show how much of your packing is complete.
4. **Edit or Delete Packing Lists, Categories, and Items**:
   - **Long press** on a packing list or category to edit or delete them.
   - **Long press** on an item to edit it, and **swipe** to delete it.


## License
This project is licensed under the [MIT License](https://github.com/jonathanvieri/Chooaca/blob/master/LICENSE)
