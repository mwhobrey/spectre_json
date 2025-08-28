# Spectre JSON Editor - Local Testing Guide

This guide will help you test the Spectre JSON Editor package locally to ensure everything is working correctly.

## 🧪 **Testing Checklist**

### **1. Code Quality Tests**
```bash
# Run static analysis
flutter analyze

# Expected result: "No issues found!"
```

### **2. Unit Tests**
```bash
# Run all tests
flutter test

# Expected result: "All tests passed!" (9 tests)
```

### **3. Package Validation**
```bash
# Test package publication (dry run)
dart pub publish --dry-run

# Expected result: "Package has 0 warnings and 1 hint"
```

### **4. Example App Testing**

#### **Option A: Run the Full Example App**
```bash
cd example
flutter run -d chrome --web-port=8080
```

#### **Option B: Run the Simple Test App**
```bash
flutter run -d chrome test_package.dart --web-port=8081
```

## 🎯 **What to Test**

### **JSON Editor Features**
1. **Dual View Mode**:
   - Switch between "Tree" and "Raw" tabs
   - Verify both views display the same data

2. **Tree View**:
   - Expand/collapse nested objects and arrays
   - Click on copy buttons for individual values
   - Verify tree structure is correct

3. **Text Editor (Raw View)**:
   - Edit JSON in the text field
   - Verify syntax highlighting works
   - Test invalid JSON (should show error)
   - Test valid JSON (should update tree view)

4. **Copy Functionality**:
   - Click copy button in header
   - Verify JSON is copied to clipboard
   - Test copy buttons in tree view

5. **Theme**:
   - Verify RedPandaTheme colors are applied
   - Check syntax highlighting colors
   - Verify dark theme appearance

### **Data Validation**
1. **Valid JSON**:
   - Edit JSON to valid format
   - Verify `onDataChanged` callback is called
   - Check that tree view updates

2. **Invalid JSON**:
   - Enter invalid JSON syntax
   - Verify error message appears
   - Check that `onDataChanged` is not called

### **Responsive Design**
1. **Resize browser window**:
   - Verify editor adapts to different sizes
   - Check that scrolling works properly
   - Test on mobile viewport

## 🔧 **Manual Testing Steps**

### **Step 1: Basic Functionality**
1. Open the example app
2. Verify the JSON editor loads with sample data
3. Check that both Tree and Raw tabs are present
4. Verify the copy button is visible

### **Step 2: Tree View Testing**
1. Click on the "Tree" tab
2. Expand nested objects and arrays
3. Click copy buttons for different values
4. Verify the tree structure is correct

### **Step 3: Text Editor Testing**
1. Click on the "Raw" tab
2. Edit the JSON text
3. Verify syntax highlighting updates
4. Test with invalid JSON (missing quotes, brackets, etc.)
5. Test with valid JSON changes

### **Step 4: Data Synchronization**
1. Make changes in the text editor
2. Switch back to tree view
3. Verify changes are reflected
4. Make changes in tree view
5. Switch to text editor
6. Verify changes are reflected

### **Step 5: Copy Functionality**
1. Click the copy button in the header
2. Paste in a text editor
3. Verify the JSON is correctly copied
4. Test copy buttons for individual values in tree view

### **Step 6: Theme Testing**
1. Verify the dark theme is applied
2. Check syntax highlighting colors
3. Verify the overall appearance matches RedPandaTheme

## 🐛 **Common Issues to Check**

### **If Tests Fail**
1. **Analysis Issues**: Run `flutter analyze` to see specific warnings
2. **Test Failures**: Check test output for specific test failures
3. **Dependency Issues**: Run `flutter pub get` to update dependencies

### **If Example App Doesn't Work**
1. **Port Issues**: Try different ports (8080, 8081, etc.)
2. **Browser Issues**: Try different browsers (Chrome, Firefox, Edge)
3. **Flutter Issues**: Run `flutter doctor` to check Flutter installation

### **If Package Validation Fails**
1. **Metadata Issues**: Check `pubspec.yaml` for missing fields
2. **Documentation Issues**: Verify all public APIs have documentation
3. **Analysis Issues**: Fix any warnings from `flutter analyze`

## 📊 **Expected Results**

### **All Tests Should Pass**
- ✅ 9/9 tests passing
- ✅ No analysis warnings
- ✅ Package validation passes
- ✅ Example app runs without errors

### **Example App Should Show**
- ✅ JSON editor with sample data
- ✅ Working Tree and Raw tabs
- ✅ Copy functionality
- ✅ Syntax highlighting
- ✅ Dark theme appearance
- ✅ Responsive design

## 🚀 **Next Steps After Testing**

If all tests pass and the example app works correctly:

1. **Commit any changes**: `git add . && git commit -m "Test results"`
2. **Push to GitHub**: `git push`
3. **Publish to pub.dev**: `dart pub publish`

## 📝 **Reporting Issues**

If you find any issues during testing:

1. **Create a GitHub issue** with detailed description
2. **Include steps to reproduce**
3. **Add screenshots if applicable**
4. **Specify your environment** (OS, Flutter version, etc.)

## 🎉 **Success Criteria**

Your package is ready for publication when:
- ✅ All tests pass
- ✅ No analysis warnings
- ✅ Example app works correctly
- ✅ All features function as expected
- ✅ Documentation is complete
- ✅ Code quality is high

Happy testing! 🧪✨
