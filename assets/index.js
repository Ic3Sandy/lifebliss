// Main communication function for Flutter interaction
function callFlutter(action, params = {}) {
    console.log(`Calling Flutter: ${action}`);
    try {
        // Format message
        const message = Object.keys(params).length > 0 
            ? JSON.stringify({ action, params }) 
            : action;
        
        // Send message if Flutter channel exists
        if (window.flutter?.postMessage) {
            window.flutter.postMessage(message);
            return true;
        } else {
            console.warn("Flutter channel not available");
            return false;
        }
    } catch (error) {
        console.error(`Error calling Flutter: ${error}`);
        return false;
    }
}

// Function to verify Flutter channel is ready
function checkFlutterChannel() {
    if (window.flutter && typeof window.flutter.postMessage === 'function') {
        console.log("Flutter channel is ready and functional");
        return true;
    }
    console.warn("Flutter channel not ready yet");
    return false;
}

// Function to set up the title element with click listeners
function setupTitleElement() {
    console.log("Setting up title element");
    const titleElement = document.getElementById('app-title');
    if (titleElement) {
        // Ensure positioning is handled by CSS
        // Remove any inline styles that might conflict
        titleElement.removeAttribute('style');
        
        // Add single click event handler with better error handling
        titleElement.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            console.log("Title clicked - requesting random color");
            
            // First change color locally as fallback
            document.body.style.backgroundColor = "#FF8800";
            
            // Then try to notify Flutter
            setTimeout(function() {
                callFlutter("titleClicked", {});
            }, 0); // Use timeout to avoid blocking the UI
        });

        // Mark the element as initialized
        titleElement.setAttribute('data-initialized', 'true');

        console.log("Click handlers attached successfully");
        
        // Verify positioning immediately after finding the element
        // (Removed setTimeout wrapper)
        const rect = titleElement.getBoundingClientRect();
        const centerX = window.innerWidth / 2;
        const centerY = window.innerHeight / 2;
        const isNearCenter = 
            Math.abs(rect.left + rect.width/2 - centerX) < 50 && 
            Math.abs(rect.top + rect.height/2 - centerY) < 50;
        
        console.log(`Title positioning: left=${rect.left}, top=${rect.top}, width=${rect.width}, height=${rect.height}`);
        console.log(`Window center: x=${centerX}, y=${centerY}`);
        console.log(`Title is ${isNearCenter ? 'centered' : 'NOT centered'}`);
        
        if (!isNearCenter) {
            console.warn("Title element is not properly centered - applying fix");
            document.body.style.display = 'flex';
            document.body.style.justifyContent = 'center';
            document.body.style.alignItems = 'center';
            document.body.style.minHeight = '100vh';
        }
    } else {
        console.error("Could not find app-title element");
    }
}

// Initialize the application
function initializeApp() {
    // Set up title click handler
    const titleElement = document.getElementById('app-title');
    if (titleElement) {
        titleElement.addEventListener('click', () => {
            document.body.style.backgroundColor = "#FF8800"; // Fallback color change
            callFlutter("titleClicked", {});
        });
    }
    
    // Set up gallery button
    const galleryButton = document.getElementById('gallery-button');
    if (galleryButton) {
        galleryButton.addEventListener('click', () => {
            callFlutter('openGallery', {});
        });
    }
}

// Initialize on DOM content loaded
document.addEventListener('DOMContentLoaded', initializeApp);

// Fallback for window load event
window.addEventListener('load', function() {
    console.log("Window loaded - checking if title setup is needed");
    const titleElement = document.getElementById('app-title');
    if (titleElement && !titleElement.hasAttribute('data-initialized')) {
        console.log("Title not set up yet - setting up now");
        setupTitleElement();
    }
    
    // Check Flutter channel again
    checkFlutterChannel();
});

// Function to initialize UI
function initializeUI() {
  // Find existing gallery button in the HTML
  const existingButton = document.getElementById('gallery-button');
  
  // If button exists in HTML, make sure it has the correct properties and listeners
  if (existingButton) {
    console.log("Found existing gallery button in HTML, enhancing it");
    // Ensure the button text is correct
    existingButton.textContent = 'Open Gallery';
    // Add click event listener (will not duplicate if using onclick in HTML)
    existingButton.addEventListener('click', function() {
      callFlutter('openGallery', {});
    });
    // No need to create a new button
    return;
  }
  
  // Only create a new button if one doesn't exist in the HTML
  console.log("No gallery button found in HTML, creating one");
  const galleryButton = document.createElement('button');
  galleryButton.id = 'gallery-button';
  galleryButton.textContent = 'Open Gallery';
  galleryButton.style.padding = '10px 15px';
  galleryButton.style.margin = '10px';
  galleryButton.style.backgroundColor = '#4CAF50';
  galleryButton.style.color = 'white';
  galleryButton.style.border = 'none';
  galleryButton.style.borderRadius = '4px';
  galleryButton.style.cursor = 'pointer';
  
  // Add click event listener to the gallery button
  galleryButton.addEventListener('click', function() {
    callFlutter('openGallery', {});
  });
  
  // Find the button container or create one if it doesn't exist
  let buttonContainer = document.querySelector('.button-container');
  if (!buttonContainer) {
    buttonContainer = document.createElement('div');
    buttonContainer.className = 'button-container';
    // Add the button container to the content div or body
    const contentDiv = document.querySelector('.content') || document.body;
    contentDiv.appendChild(buttonContainer);
  }
  
  // Append the button to the button container
  buttonContainer.appendChild(galleryButton);
}

// Call initializeUI when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // ... existing code ...
  
  initializeUI();
}); 