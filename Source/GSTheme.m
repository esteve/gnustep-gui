/** <title>GSTheme</title>

   <abstract>Useful/configurable drawing functions</abstract>

   Copyright (C) 2004 Free Software Foundation, Inc.

   Author: Adam Fedor <fedor@gnu.org>
   Date: Jan 2004
   
   This file is part of the GNU Objective C User interface library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#import <Foundation/NSBundle.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSUserDefaults.h>
#import "GNUstepBase/GSObjCRuntime.h"
#import "GNUstepGUI/GSTheme.h"
#import "AppKit/NSApplication.h"
#import "AppKit/NSButtonCell.h"
#import "AppKit/NSButton.h"
#import "AppKit/NSColor.h"
#import "AppKit/NSColorList.h"
#import "AppKit/NSGraphics.h"
#import "AppKit/NSImage.h"
#import "AppKit/NSImageView.h"
#import "AppKit/NSMatrix.h"
#import "AppKit/NSMenu.h"
#import "AppKit/NSPanel.h"
#import "AppKit/NSScrollView.h"
#import "AppKit/NSSegmentedControl.h"
#import "AppKit/NSTextContainer.h"
#import "AppKit/NSTextField.h"
#import "AppKit/NSTextView.h"
#import "AppKit/NSScrollView.h"
#import "AppKit/NSView.h"
#import "AppKit/NSWindow.h"
#import "AppKit/NSBezierPath.h"
#import "AppKit/PSOperators.h"
#import "GSThemePrivate.h"

// Scroller part names
NSString	*GSScrollerDownArrow = @"GSScrollerDownArrow";
NSString	*GSScrollerHorizontalKnob = @"GSScrollerHorizontalKnob";
NSString	*GSScrollerHorizontalSlot = @"GSScrollerHorizontalSlot";
NSString	*GSScrollerLeftArrow = @"GSScrollerLeftArrow";
NSString	*GSScrollerRightArrow = @"GSScrollerRightArrow";
NSString	*GSScrollerUpArrow = @"GSScrollerUpArrow";
NSString	*GSScrollerVerticalKnob = @"GSScrollerVerticalKnob";
NSString	*GSScrollerVerticalSlot = @"GSScrollerVerticalSlot";

// Table view part names
NSString	*GSTableHeader = @"GSTableHeader";
NSString	*GSTableCorner = @"GSTableCorner";

// Browser part names
NSString        *GSBrowserHeader = @"GSBrowserHeader";

// Menu part names
NSString        *GSMenuHorizontalBackground = @"GSMenuHorizontalBackground";
NSString        *GSMenuVerticalBackground = @"GSMenuVerticalBackground";
NSString        *GSMenuHorizontalItem = @"GSMenuHorizontalItem";
NSString        *GSMenuVerticalItem = @"GSMenuVerticalItem";

// Progress indicator part names
NSString        *GSProgressIndicatorBarDeterminate 
  = @"GSProgressIndicatorBarDeterminate";

// Color well part names
NSString	*GSColorWell = @"GSColorWell";

NSString	*GSThemeDidActivateNotification
  = @"GSThemeDidActivateNotification";
NSString	*GSThemeDidDeactivateNotification
  = @"GSThemeDidDeactivateNotification";
NSString	*GSThemeWillActivateNotification
  = @"GSThemeWillActivateNotification";
NSString	*GSThemeWillDeactivateNotification
  = @"GSThemeWillDeactivateNotification";

NSString *
GSThemeStringFromFillStyle(GSThemeFillStyle s)
{
  switch (s)
    {
      case GSThemeFillStyleNone: return @"None";
      case GSThemeFillStyleScale: return @"Scale";
      case GSThemeFillStyleRepeat: return @"Repeat";
      case GSThemeFillStyleCenter: return @"Center";
      case GSThemeFillStyleMatrix: return @"Matrix";
      case GSThemeFillStyleScaleAll: return @"ScaleAll";
    }
  return nil;
}

GSThemeFillStyle
GSThemeFillStyleFromString(NSString *s)
{
  if (s == nil || [s isEqualToString: @"None"])
    {
      return GSThemeFillStyleNone;
    }
  if ([s isEqualToString: @"Scale"])
    {
      return GSThemeFillStyleScale;
    }
  if ([s isEqualToString: @"Repeat"])
    {
      return GSThemeFillStyleRepeat;
    }
  if ([s isEqualToString: @"Center"])
    {
      return GSThemeFillStyleCenter;
    }
  if ([s isEqualToString: @"Matrix"])
    {
      return GSThemeFillStyleMatrix;
    }
  if ([s isEqualToString: @"ScaleAll"])
    {
      return GSThemeFillStyleScaleAll;
    }
  return GSThemeFillStyleNone;
}

NSString *
GSStringFromSegmentStyle(NSSegmentStyle segmentStyle)
{
  switch (segmentStyle)
    {
      case NSSegmentStyleAutomatic:       return @"NSSegmentStyleAutomatic";
      case NSSegmentStyleRounded:         return @"NSSegmentStyleRounded";
      case NSSegmentStyleTexturedRounded: return @"NSSegmentStyleTexturedRounded";
      case NSSegmentStyleRoundRect:       return @"NSSegmentStyleRoundRect";
      case NSSegmentStyleTexturedSquare:  return @"NSSegmentStyleTexturedSquare";
      case NSSegmentStyleCapsule:         return @"NSSegmentStyleCapsule";
      case NSSegmentStyleSmallSquare:     return @"NSSegmentStyleSmallSquare";
      default:                            return nil;
    }
}

NSString *
GSStringFromBezelStyle(NSBezelStyle bezelStyle)
{
  switch (bezelStyle)
    {
      case NSRoundedBezelStyle:           return @"NSRoundedBezelStyle";
      case NSRegularSquareBezelStyle:     return @"NSRegularSquareBezelStyle";
      case NSThickSquareBezelStyle:       return @"NSThickSquareBezelStyle";
      case NSThickerSquareBezelStyle:     return @"NSThickerSquareBezelStyle";
      case NSDisclosureBezelStyle:        return @"NSDisclosureBezelStyle";
      case NSShadowlessSquareBezelStyle:  return @"NSShadowlessSquareBezelStyle";
      case NSCircularBezelStyle:          return @"NSCircularBezelStyle";
      case NSTexturedSquareBezelStyle:    return @"NSTexturedSquareBezelStyle";
      case NSHelpButtonBezelStyle:        return @"NSHelpButtonBezelStyle";
      case NSSmallSquareBezelStyle:       return @"NSSmallSquareBezelStyle";
      case NSTexturedRoundedBezelStyle:   return @"NSTexturedRoundedBezelStyle";
      case NSRoundRectBezelStyle:         return @"NSRoundRectBezelStyle";
      case NSRecessedBezelStyle:          return @"NSRecessedBezelStyle";
      case NSRoundedDisclosureBezelStyle: return @"NSRoundedDisclosureBezelStyle";
      case NSNeXTBezelStyle:              return @"NSNeXTBezelStyle";
      case NSPushButtonBezelStyle:        return @"NSPushButtonBezelStyle";
      case NSSmallIconButtonBezelStyle:   return @"NSSmallIconButtonBezelStyle";
      case NSMediumIconButtonBezelStyle:  return @"NSMediumIconButtonBezelStyle";
      case NSLargeIconButtonBezelStyle:   return @"NSLargeIconButtonBezelStyle";
      default:                            return nil;
    }
}

NSString *
GSStringFromBorderType(NSBorderType borderType)
{
  switch (borderType)
    {
      case NSNoBorder:                    return @"NSNoBorder";
      case NSLineBorder:                  return @"NSLineBorder";
      case NSBezelBorder:                 return @"NSBezelBorder";
      case NSGrooveBorder:                return @"NSGrooveBorder";
      default:                            return nil;
    }
}



@interface	NSImage (GSTheme)
+ (NSImage*) _setImage: (NSImage*)image name: (NSString*)name;
@end

@interface	GSTheme (Private)
- (void) _revokeOwnerships;
@end

/* This private internal class is used to store information about a method
 * in some other class which is overridden while the current theme is
 * active.
 */
@interface GSThemeMethod : NSObject
{
@public
  Class		cls;
  SEL		sel;
  IMP		imp;	// The new method implementation
  IMP		old;	// The original method implementation
  Method	mth;	// The method information
}
@end

@implementation	GSThemeMethod
@end

@implementation GSTheme

static GSTheme			*defaultTheme = nil;
static NSString			*currentThemeName = nil;
static GSTheme			*theTheme = nil;
static NSMutableDictionary	*themes = nil;
static NSNull			*null = nil;
static NSMapTable		*names = 0;

typedef	struct {
  NSBundle		*bundle;
  NSColorList		*colors;
  NSColorList		*extraColors[GSThemeSelectedState+1];
  NSMutableDictionary	*images;
  NSMutableDictionary	*oldImages;
  NSMutableDictionary	*tiles[GSThemeSelectedState+1];
  NSMutableSet		*owned;
  NSImage		*icon;
  NSString		*name;
  Class			colorClass;
  Class			imageClass;
  NSMutableArray	*overrides;
} internal;

#define	_internal 		((internal*)_reserved)
#define	_bundle			_internal->bundle
#define	_colors			_internal->colors
#define	_extraColors		_internal->extraColors
#define	_images			_internal->images
#define	_oldImages		_internal->oldImages
#define	_tiles			_internal->tiles
#define	_owned			_internal->owned
#define	_icon			_internal->icon
#define	_name			_internal->name
#define	_colorClass		_internal->colorClass
#define	_imageClass		_internal->imageClass
#define	_overrides		_internal->overrides

+ (void) defaultsDidChange: (NSNotification*)n
{
  NSUserDefaults	*defs;
  NSString		*name;

  defs = [NSUserDefaults standardUserDefaults];
  name = [defs stringForKey: @"GSTheme"];
  if (name != currentThemeName && [name isEqual: currentThemeName] == NO)
    {
      [self setTheme: [self loadThemeNamed: name]];
      ASSIGN(currentThemeName, name);	// Don't try to load again.
    }
}

+ (void) initialize
{
  if (themes == nil)
    {
      themes = [NSMutableDictionary new];
      [[NSNotificationCenter defaultCenter]
	addObserver: self
	selector: @selector(defaultsDidChange:)
	name: NSUserDefaultsDidChangeNotification
	object: nil];
      null = RETAIN([NSNull null]);
      defaultTheme = [[self alloc] initWithBundle: nil];
      ASSIGN(theTheme, defaultTheme);
      ASSIGN(currentThemeName, [defaultTheme name]);
      names = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
	NSIntMapValueCallBacks, 0);
    }
  /* Establish the theme specified by the user defaults (if any);
   */
  [self defaultsDidChange: nil];
}

+ (GSTheme*) loadThemeNamed: (NSString*)aName
{
  NSBundle	*bundle;
  Class		cls;
  GSTheme	*instance;
  NSString	*theme;

  if ([aName length] == 0)
    {
      return defaultTheme;
    }

  if ([aName isAbsolutePath] == YES)
    {
      theme = aName;
    }
  else
    {
      aName = [aName lastPathComponent];

      /* Ensure that the theme name has the 'theme' extension.
       */
      if ([[aName pathExtension] isEqualToString: @"theme"] == YES)
	{
	  theme = aName;
	}
      else
	{
	  theme = [aName stringByAppendingPathExtension: @"theme"];
	}
      if ([theme isEqualToString: @"GNUstep.theme"] == YES)
	{
	  return defaultTheme;
	}
    }

  bundle = [themes objectForKey: theme];
  if (bundle == nil)
    {
      NSString		*path = nil;
      NSFileManager	*mgr = [NSFileManager defaultManager];
      BOOL 		isDir;

      /* A theme may be either an absolute path or a filename to be located
       * in the Themes subdirectory of one of the standard Library directories.
       */
      if ([theme isAbsolutePath] == YES)
        {
	  if ([mgr fileExistsAtPath: theme isDirectory: &isDir] == YES
	    && isDir == YES)
	    {
	      path = theme;
	    }
	}
      else
        {
	  NSEnumerator	*enumerator;

	  enumerator = [NSSearchPathForDirectoriesInDomains
	    (NSAllLibrariesDirectory, NSAllDomainsMask, YES) objectEnumerator];
	  while ((path = [enumerator nextObject]) != nil)
	    {
	      path = [path stringByAppendingPathComponent: @"Themes"];
	      path = [path stringByAppendingPathComponent: theme];
	      if ([mgr fileExistsAtPath: path isDirectory: &isDir])
		{
		  break;
		}
	    }
	}

      if (path == nil)
	{
	  NSLog (@"No theme named '%@' found", aName);
	  return nil;
	}
      else
        {
	  bundle = [NSBundle bundleWithPath: path];
	  [themes setObject: bundle forKey: theme];
	  [bundle load];	// Ensure code is loaded.
	}
    }

  cls = [bundle principalClass];
  if (cls == 0)
    {
      cls = self;
    }
  instance = [[cls alloc] initWithBundle: bundle];
  return AUTORELEASE(instance);
}

+ (void) orderFrontSharedThemePanel: (id)sender
{
  GSThemePanel *panel;

  panel = [GSThemePanel sharedThemePanel];
  [panel update: self];
  [panel center];
  [panel orderFront: self];
}

+ (void) setTheme: (GSTheme*)theme
{
  if (theme == nil)
    {
      theme = defaultTheme;
    }
  if (theme != theTheme)
    {
      [theTheme deactivate];
      DESTROY(currentThemeName);
      ASSIGN (theTheme, theme);
      [theTheme activate];
      ASSIGN(currentThemeName, [theTheme name]);
    }
}

+ (GSTheme*) theme 
{
  return theTheme;
}

- (void) activate
{
  NSUserDefaults	*defs;
  NSMutableArray	*searchList;
  NSArray		*imagePaths;
  NSEnumerator		*enumerator;
  NSString		*imagePath;
  NSArray		*imageTypes;
  NSDictionary		*infoDict;
  NSWindow		*window;
  GSThemeControlState	state;
  
  NSDebugMLLog(@"GSTheme", @"%@ %p", [self name], self);
  /* Get rid of any cached colors list so that we regenerate it when needed
   */
  [_colors release];
  _colors = nil;
  for (state = 0; state <= GSThemeSelectedState; state++)
    {
      [_extraColors[state] release];
      _extraColors[state] = nil;
    }

  /*
   * We step through all the bundle image resources and load them in
   * to memory, setting their names so that they are visible to
   * [NSImage+imageNamed:] and storing them in our local array.
   */
  imageTypes = [_imageClass imageFileTypes];
  imagePaths = [_bundle pathsForResourcesOfType: nil
				    inDirectory: @"ThemeImages"];
  enumerator = [imagePaths objectEnumerator];
  while ((imagePath = [enumerator nextObject]) != nil)
    {
      NSString	*ext = [imagePath pathExtension];

      if (ext != nil && [imageTypes containsObject: ext] == YES)
        {
	  NSImage	*image;
	  NSString	*imageName;

	  imageName = [imagePath lastPathComponent];
	  imageName = [imageName stringByDeletingPathExtension];

	  image = [_images objectForKey: imageName];
	  if (image == nil)
	    {
	      image = [[_imageClass alloc] initWithContentsOfFile: imagePath];
	      if (image == nil)
		{
		  NSLog(@"GSTheme failed to load %@ from %@",
		    imageName, imagePath);
		}
	      else
		{
		  NSImage	*old;

		  /* OK, we have loaded a new image, so we cache it for the
		   * lifetime of the theme, and we also make a record of
		   * any previous/default image of the same name.
		   */
		  [_images setObject: image forKey: imageName];
		  RELEASE(image);
		  old = [NSImage imageNamed: imageName];
		  if (old == nil)
		    {
		      /* This could potentially be a real problem ... if the
		       * image from the current theme with this name is used
		       * and the theme is unloaded, what happens when the
		       * app tries to draw using the proxy to the unloaded
		       * image?
		       * To avoid that possibility, we save the new image
		       * as if it were the old one ... so when the theme is
		       * unloaded the old image persists.
		       */
		      [_oldImages setObject: image forKey: imageName];
		    }
		  else
		    {
		      /* Store the actual image, not the proxy.
		       */
		      old = [(id)old _resource];
		      [_oldImages setObject: old forKey: imageName];
		    }
		}
	    }

	  /* We try to ensure that our new image can be found by name.
	   */
	  if (image != nil && [[image name] isEqualToString: imageName] == NO)
	    {
	      [NSImage _setImage: image name: imageName];
	    }
	}
    }

  /*
   * Use the GSThemeDomain key in the info dictionary of the theme to
   * set a defaults domain which will establish user defaults values
   * but will not override any defaults set explicitly by the user.
   * NB. For subclasses, the theme info dictionary may not be the same
   * as that of the bundle, so we don't use the bundle method directly.
   */
  infoDict = [self infoDictionary];
  defs = [NSUserDefaults standardUserDefaults];
  searchList = [[defs searchList] mutableCopy];
  if ([[infoDict objectForKey: @"GSThemeDomain"] isKindOfClass:
    [NSDictionary class]] == YES)
    {
      [defs removeVolatileDomainForName: @"GSThemeDomain"];
      [defs setVolatileDomain: [infoDict objectForKey: @"GSThemeDomain"]
		      forName: @"GSThemeDomain"];
      if ([searchList containsObject: @"GSThemeDomain"] == NO)
	{
	  unsigned	index;

	  /*
	   * Higher priority than GSConfigDomain and NSRegistrationDomain,
	   * but lower than NSGlobalDomain, NSArgumentDomain, and others
	   * set by the user to be application specific.
	   */
	  index = [searchList indexOfObject: GSConfigDomain];
	  if (index == NSNotFound)
	    {
	      index = [searchList indexOfObject: NSRegistrationDomain];
	      if (index == NSNotFound)
	        {
		  index = [searchList count];
		}
	    }
	  [searchList insertObject: @"GSThemeDomain" atIndex: index];
	  [defs setSearchList: searchList];
	}
    }
  else
    {
      [searchList removeObject: @"GSThemeDomain"];
      [defs removeVolatileDomainForName: @"GSThemeDomain"];
    }
  RELEASE(searchList);

  /* Install any overridden methods.
   */
  if (_overrides != nil)
    {
      NSEnumerator	*e = [_overrides objectEnumerator];
      GSThemeMethod	*m;

      while ((m = [e nextObject]) != nil)
	{
	  method_setImplementation(m->mth, m->imp);
	}
    }

  /*
   * Tell subclass that basic activation is done and it can do its own.
   */
  [[NSNotificationCenter defaultCenter]
    postNotificationName: GSThemeWillActivateNotification
    object: self
    userInfo: nil];

  /*
   * Tell all other classes that new theme information is present.
   */
  [[NSNotificationCenter defaultCenter]
    postNotificationName: GSThemeDidActivateNotification
    object: self
    userInfo: nil];

  /*
   * Reset main menu to change between styles if necessary
   */
  [[NSApp mainMenu] setMain: YES];

  /*
   * Mark all windows as needing redisplaying to show the new theme.
   */
  enumerator = [[NSApp windows] objectEnumerator];
  while ((window = [enumerator nextObject]) != nil)
    {
      [[[window contentView] superview] setNeedsDisplay: YES];
    }
}

- (NSArray*) authors
{
  return [[self infoDictionary] objectForKey: @"GSThemeAuthors"];
}

- (NSBundle*) bundle
{
  return _bundle;
}

- (Class) colorClass
{
  return [NSColorList class];
}

- (void) colorFlush: (NSString*)aName
	      state: (GSThemeControlState)elementState
{
  int	pos;
  int	end;

  if (elementState > GSThemeSelectedState)
    {
      pos = 0;
      end = GSThemeSelectedState;
    }
  else
    {
      pos = elementState;
      end = elementState;
    }
  while (pos <= end)
    {
      if (_extraColors[pos] != nil)
	{
	  [_extraColors[pos] release];
	  _extraColors[pos] = nil;
	}
      pos++;
    }
}

- (NSColor*) colorNamed: (NSString*)aName
		  state: (GSThemeControlState)elementState
{
  NSColor	*c = nil;

  NSAssert(elementState <= GSThemeSelectedState, NSInvalidArgumentException);
  NSAssert(elementState >= 0, NSInvalidArgumentException);

  if (aName != nil)
    {
      if (_extraColors[elementState] == nil)
	{
	  NSString	*colorsPath;
	  NSString	*listName;
	  NSString	*resourceName;

	  /* Attempt to load color list ... if the list is not found
	   * or the load fails, set a null marker.
	   */
	  switch (elementState)
	    {
              default:
	      case GSThemeNormalState:
		listName = @"ThemeExtra";
		break;
	      case GSThemeHighlightedState:
		listName = @"ThemeExtraHighlighted";
		break;
	      case GSThemeSelectedState:
		listName = @"ThemeExtraSelected";
		break;
	    }
	  resourceName = [listName stringByAppendingString: @"Colors"];
	  colorsPath = [_bundle pathForResource: resourceName
					 ofType: @"clr"]; 
	  if (colorsPath != nil)
	    {
	      _extraColors[elementState]
		= [[_colorClass alloc] initWithName: listName
					   fromFile: colorsPath];
	      /* If the list is actually empty, we get rid of it to avoid
	       * unnecessary lookups.
	       */
	      if ([[_extraColors[elementState] allKeys] count] == 0)
		{
		  [_extraColors[elementState] release];
		  _extraColors[elementState] = nil;
		}
	    }
	  if (_extraColors[elementState] == nil)
	    {
	      _extraColors[elementState] = [null retain];
	    }
	}
      if (_extraColors[elementState] != (id)null)
	{
          c = [_extraColors[elementState] colorWithKey: aName];
	}
    }
  return c;
}

- (NSColorList*) colors
{
  if (_colors == nil)
    {
      NSString	*colorsPath;

      colorsPath = [_bundle pathForResource: @"ThemeColors" ofType: @"clr"]; 
      if (colorsPath == nil)
	{
	  _colors = [null retain];
	}
      else
	{
	  _colors = [[_colorClass alloc] initWithName: @"System"
					     fromFile: colorsPath];
	}
    }
  if ((id)_colors == (id)null)
    {
      return nil;
    }
  return _colors;
}

- (void) deactivate
{
  NSEnumerator	*enumerator;
  NSImage	*image;
  NSString	*name;

  NSDebugMLLog(@"GSTheme", @"%@ %p", [self name], self);

  /* Tell everything that we will become inactive.
   */
  [[NSNotificationCenter defaultCenter]
    postNotificationName: GSThemeWillDeactivateNotification
    object: self
    userInfo: nil];

  /* Remove any overridden methods.
   */
  if (_overrides != nil)
    {
      NSEnumerator	*e = [_overrides objectEnumerator];
      GSThemeMethod	*m;

      while ((m = [e nextObject]) != nil)
	{
	  method_setImplementation(m->mth, m->old);
	}
    }

  /* Unload all images created by this theme.
   */
  enumerator = [_images objectEnumerator];
  while ((image = [enumerator nextObject]) != nil)
    {
      [image setName: nil];
    }
  [_images removeAllObjects];

  /* Restore old images in NSImage's lookup dictionary so that the app
   * still has images to draw.
   * The remove all cached bundle images from both NSImage's name dictionary
   * and our cache dictionary, so that we can be sure we reload afresh
   * when re-activated (in case the images on disk changed ... eg by a
   * theme editor modifying the theme).
   */
  enumerator = [_oldImages keyEnumerator];
  while ((name = [enumerator nextObject]) != nil)
    {
      image = [_oldImages objectForKey: name];
      [NSImage _setImage: image name: name];
    }
  [_oldImages removeAllObjects];

  [self _revokeOwnerships];

  /* Tell everything that we have become inactive.
   */
  [[NSNotificationCenter defaultCenter]
    postNotificationName: GSThemeDidDeactivateNotification
    object: self
    userInfo: nil];
}

- (void) dealloc
{
  if (_reserved != 0)
    {
      GSThemeControlState	state;

      for (state = 0; state <= GSThemeSelectedState; state++)
	{
          RELEASE(_extraColors[state]);
          RELEASE(_tiles[state]);
	}
      RELEASE(_bundle);
      RELEASE(_colors);
      RELEASE(_images);
      RELEASE(_oldImages);
      RELEASE(_icon);
      [self _revokeOwnerships];
      RELEASE(_overrides);
      RELEASE(_owned);
      NSZoneFree ([self zone], _reserved);
    }
  [super dealloc];
}

- (NSImage*) icon
{
  if (_icon == nil)
    {
      NSString	*path;

      path = [[self infoDictionary] objectForKey: @"GSThemeIcon"];
      if (path != nil)
        {
	  NSString	*ext = [path pathExtension];

	  path = [path stringByDeletingPathExtension];
	  path = [_bundle pathForResource: path ofType: ext];
	  if (path != nil)
	    {
	      _icon = [[_imageClass alloc] initWithContentsOfFile: path];
	    }
	}
      if (_icon == nil)
        {
	  _icon = RETAIN([_imageClass imageNamed: @"GNUstep"]);
	}
      else
	{
	  NSSize	s = [_icon size];
	  float		scale = 1.0;

	  if (s.height > 48.0)
	    scale = 48.0 / s.height;
	  if (48.0 / s.width < scale)
	    scale = 48.0 / s.width;
	  if (scale != 1.0)
	    {
	      [_icon setScalesWhenResized: YES];
	      s.height *= scale;
	      s.width *= scale;
	      [_icon setSize: s];
	    }
	}
    }
  return _icon;
}

- (Class) imageClass
{
  return [NSImage class];
}

- (id) initWithBundle: (NSBundle*)bundle
{
  Class				c = [self class];
  unsigned int			count;
  Method			*methods;
  GSThemeMethod			*mth;
  GSThemeControlState		state;

  _reserved = NSZoneCalloc ([self zone], 1, sizeof(internal));

  ASSIGN(_bundle, bundle);
  _images = [NSMutableDictionary new];
  _oldImages = [NSMutableDictionary new];
  for (state = 0; state <= GSThemeSelectedState; state++)
    {
      _tiles[state] = [NSMutableDictionary new];
    }
  _owned = [NSMutableSet new];

  ASSIGN(_name,
    [[[_bundle bundlePath] lastPathComponent] stringByDeletingPathExtension]);

  _colorClass = [self colorClass];
  _imageClass = [self imageClass];

  /* Now we look through our methods to find those which are actually
   * replacements to override methods in other classes.
   * That's determined by method name ... any method of the form
   * '_override' <classname> 'Method_' <originalmethodname>
   * is used to replace the original method in the class.
   * We maintain dictionaries (keyed by class) for instance and class
   * methods, so we can look up the original methods at runtime if the
   * replacement methods want to call them.
   */
  methods = class_copyMethodList(c, &count);
  if (methods != NULL)
    {
      int counter = 0;

      while (methods[counter] != 0)
	{
          Method	method = methods[counter++];
	  const char	*name = sel_getName(method_getName(method));
	  const char	*ptr;

	  if (strncmp(name, "_override", 9) == 0
	    && (ptr = strstr(name, "Method_")) > 0)
	    {
	      char		buf[strlen(name)];
	      const char	*types;

	      mth = [[GSThemeMethod new] autorelease];
	      types = method_getTypeEncoding(method);
	      mth->imp = method_getImplementation(method);
	      memcpy(buf, name + 9, (ptr - name) + 9);
	      buf[(ptr - name) + 9] = '\0';
	      mth->cls = objc_lookUpClass(buf);
	      if (mth->cls == 0)
		{
		  NSLog(@"Unable to find class '%s' for '%s'", buf, name);
		  continue;
		}
	      memcpy(buf, ptr + 7, strlen(ptr + 7));
	      buf[strlen(ptr + 7)] = '\0';
	      mth->sel = sel_getUid(buf);
	      if (mth->sel == 0)
		{
		  NSLog(@"Unable to find selector '-%s' for '%s'", buf, name);
		  continue;
		}
	      if (NO == [mth->cls instancesRespondToSelector: mth->sel])
		{
		  NSLog(@"Instances do not respond for '%s'", name);
		  continue;
		}
	      mth->old = [mth->cls instanceMethodForSelector: mth->sel];
	      class_addMethod(mth->cls, mth->sel, mth->imp, types);
	      mth->mth = class_getInstanceMethod(mth->cls, mth->sel);

	      if (_overrides == nil)
		{
		  _overrides = [NSMutableArray new];
		}
	      [_overrides addObject: mth];
	    }
	}
      free(methods);
    }

  methods = class_copyMethodList(object_getClass(c), &count);
  if (methods != NULL)
    {
      int counter = 0;

      while (methods[counter] != 0)
	{
          Method	method = methods[counter++];
	  const char	*name = sel_getName(method_getName(method));
	  const char	*ptr;

	  if (strncmp(name, "_override", 9) == 0
	    && (ptr = strstr(name, "Method_")) > 0)
	    {
	      char		buf[strlen(name)];
	      const char	*types;
	      Class		cls;

	      mth = [[GSThemeMethod new] autorelease];
	      types = method_getTypeEncoding(method);
		      mth->imp = method_getImplementation(method);
	      memcpy(buf, name + 9, (ptr - name) + 9);
	      buf[(ptr - name) + 9] = '\0';
	      cls = objc_lookUpClass(buf);
	      if (cls == 0)
		{
		  NSLog(@"Unable to find class '%s' for '%s'", buf, name);
		  continue;
		}
	      mth->cls = object_getClass(cls);
	      memcpy(buf, ptr + 7, strlen(ptr + 7));
	      buf[strlen(ptr + 7)] = '\0';
	      mth->sel = sel_getUid(buf);
	      if (mth->sel == 0)
		{
		  NSLog(@"Unable to find selector '-%s' for '%s'", buf, name);
		  continue;
		}
	      if (NO == [cls respondsToSelector: mth->sel])
		{
		  NSLog(@"Class does not respond for '%s'", name);
		  continue;
		}
	      mth->old = [cls methodForSelector: mth->sel];
	      class_addMethod(mth->cls, mth->sel, mth->imp, types);
	      mth->mth = class_getClassMethod(cls, mth->sel);

	      if (_overrides == nil)
		{
		  _overrides = [NSMutableArray new];
		}
	      [_overrides addObject: mth];
	    }
	}
      free(methods);
    }

  return self;
}

- (NSDictionary*) infoDictionary
{
  return [_bundle infoDictionary];
}

- (NSString*) name
{
  if (self == defaultTheme)
    {
      _name = @"GNUstep";
    }
  return _name;
}

- (NSString*) nameForElement: (id)anObject
{
  NSString	*name = (NSString*)NSMapGet(names, (void*)anObject);

  return name;
}

- (IMP) overriddenMethod: (SEL)selector for: (id)receiver
{
  Class		cls = object_getClass(receiver);
  NSEnumerator	*e = [_overrides objectEnumerator];
  GSThemeMethod	*m;

  while ((m = [e nextObject]) != nil)
    {
      if (m->cls == cls && sel_isEqual(selector, m->sel))
	{
	  return m->old;
	}
    }
  return (IMP)0;
}

- (void) setName: (NSString*)aString
{
  if (self != defaultTheme)
    {
      ASSIGNCOPY(_name, aString);
    }
}

- (void) setName: (NSString*)aString
      forElement: (id)anObject
       temporary: (BOOL)takeOwnership
{
  if (aString == nil)
    {
      if (anObject == nil)
	{
	  /* Ignore this ... it's most likely a partially initialised
	   * control being deallocated and removing the name for a
	   * subsidiary item which was never allocated in the first place.
	   */
	  return;
	}
      NSMapRemove(names, (void*)anObject);
      [_owned removeObject: anObject];
    }
  else
    {
      if (anObject == nil)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"[%@-%@] nil object supplied",
	    NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
	}
      NSMapInsert(names, (void*)anObject, (void*)aString);
      if (takeOwnership == YES)
	{
	  [_owned addObject: anObject];
	}
      else
	{
	  [_owned removeObject: anObject];
	}
    }
}

- (NSWindow*) themeInspector
{
  return [GSThemeInspector sharedThemeInspector];
}

- (void) tilesFlush: (NSString*)aName
	      state: (GSThemeControlState)elementState
{
  int	pos;
  int	end;

  if (elementState > GSThemeSelectedState)
    {
      pos = 0;
      end = GSThemeSelectedState;
    }
  else
    {
      pos = elementState;
      end = elementState;
    }
  while (pos <= end)
    {
      NSMutableDictionary	*cache;

      cache = _tiles[pos++];
      if (aName == nil)
	{
	  return [cache removeAllObjects];
	}
      else
	{
	  [cache removeObjectForKey: aName];
	}
    }
}

- (GSDrawTiles*) tilesNamed: (NSString*)aName
		      state: (GSThemeControlState)elementState
{
  GSDrawTiles		*tiles;
  NSMutableDictionary	*cache;

  NSAssert(elementState <= GSThemeSelectedState, NSInvalidArgumentException);
  NSAssert(elementState >= 0, NSInvalidArgumentException);
  if (aName == nil)
    {
      return nil;
    }
  cache = _tiles[elementState];
  tiles = [cache objectForKey: aName];
  if (tiles == nil)
    {
      NSDictionary	*info;
      NSImage		*image;
      NSString		*fullName;

      switch (elementState)
	{
          default:
	  case GSThemeNormalState:
	    fullName = aName;
	    break;
	  case GSThemeDisabledState:
	    fullName = [aName stringByAppendingString: @"Disabled"];
	    break;
	  case GSThemeHighlightedState:
	    fullName = [aName stringByAppendingString: @"Highlighted"];
	    break;
	  case GSThemeSelectedState:
	    fullName = [aName stringByAppendingString: @"Selected"];
	    break;
	}

      /* The GSThemeTiles entry in the info dictionary should be a
       * dictionary containing information about each set of tiles.
       * Keys are:
       * FileName		Name of the file in the ThemeTiles directory
       * HorizontalDivision	Where to divide the image into columns.
       * VerticalDivision	Where to divide the image into rows.
       */
      info = [self infoDictionary];
      info = [[info objectForKey: @"GSThemeTiles"] objectForKey: fullName];
      if ([info isKindOfClass: [NSDictionary class]] == YES)
        {
	  float			x;
	  float			y;
	  NSString		*name;
	  NSString		*path;
	  NSString		*file;
	  NSString		*ext;
	  GSThemeFillStyle	style;

	  name = [info objectForKey: @"FillStyle"];
	  style = GSThemeFillStyleFromString(name);
	  if (style < GSThemeFillStyleNone) style = GSThemeFillStyleNone;
	  x = [[info objectForKey: @"HorizontalDivision"] floatValue];
	  y = [[info objectForKey: @"VerticalDivision"] floatValue];
	  file = [info objectForKey: @"FileName"];
	  ext = [file pathExtension];
	  file = [file stringByDeletingPathExtension];
	  path = [_bundle pathForResource: file
				   ofType: ext
			      inDirectory: @"ThemeTiles"];
	  if (path == nil)
	    {
	      NSLog(@"File %@.%@ not found in ThemeTiles", file, ext);
	    }
	  else
	    {
	      image = [[_imageClass alloc] initWithContentsOfFile: path];
	      if (image != nil)
		{
                  if ([[info objectForKey: @"NinePatch"] boolValue])
                    {
                      tiles = [[GSDrawTiles alloc]
			initWithNinePatchImage: image];
		      [tiles setFillStyle: GSThemeFillStyleScaleAll];
                    }
                  else
                    {
		      tiles = [[GSDrawTiles alloc] initWithImage: image
                                                      horizontal: x
                                                        vertical: y];
		      [tiles setFillStyle: style];
                    }
		  RELEASE(image);
		}
	    }
	}
      else
        {
	  NSArray	*imageTypes;
	  NSString	*imagePath;
	  unsigned	count;

	  imageTypes = [_imageClass imageFileTypes];
	  for (count = 0; count < [imageTypes count]; count++)
	    {
	      NSString	*ext = [imageTypes objectAtIndex: count];

	      imagePath = [_bundle pathForResource: fullName
					    ofType: ext
				       inDirectory: @"ThemeTiles"];
	      if (imagePath != nil)
		{
		  image
		    = [[_imageClass alloc] initWithContentsOfFile: imagePath];
		  if (image != nil)
		    {
		      tiles = [[GSDrawTiles alloc] initWithImage: image];
		      RELEASE(image);
		      break;
		    }
		}
	    }
	}

      if (tiles == nil)
        {
	  [cache setObject: null forKey: aName];
	}
      else
        {
	  [cache setObject: tiles forKey: aName];
	  RELEASE(tiles);
	}
    }
  if (tiles == (id)null)
    {
      tiles = nil;
    }
  return tiles;
}

- (NSString*) versionString
{
  return [[self infoDictionary] objectForKey: @"GSThemeVersion"];
}

@end

@implementation	GSTheme (Private)
/* Remove all temporarily named objects from our registry, releasing them.
 */
- (void) _revokeOwnerships
{
  id	o;

  while ((o = [_owned anyObject]) != nil)
    {
      [self setName: nil forElement: o temporary: YES];
    }
}
@end

@implementation	GSThemeProxy
- (id) _resource
{
  return _resource;
}
- (void) _setResource: (id)resource
{
  ASSIGN(_resource, resource);
}
- (void) dealloc
{
  DESTROY(_resource);
  [super dealloc];
}
- (NSString*) description
{
  return [_resource description];
}
- (id) forwardingTargetForSelector:(SEL)aSelector
{
  return _resource;
}
- (void) forwardInvocation: (NSInvocation*)anInvocation
{
  [anInvocation invokeWithTarget: _resource];
}
- (NSMethodSignature*) methodSignatureForSelector: (SEL)aSelector
{
  if (_resource != nil)
    {
      return [_resource methodSignatureForSelector: aSelector];
    }
  else
    {
      /*
       * Evil hack to prevent recursion - if we are asking a remote
       * object for a method signature, we can't ask it for the
       * signature of methodSignatureForSelector:, so we hack in
       * the signature required manually :-(
       */
      if (sel_isEqual(aSelector, _cmd))
	{
	  static	NSMethodSignature	*sig = nil;

	  if (sig == nil)
	    {
	      sig = RETAIN([NSMethodSignature signatureWithObjCTypes: "@@::"]);
	    }
	  return sig;
	}
      return nil;
    }
}
@end

