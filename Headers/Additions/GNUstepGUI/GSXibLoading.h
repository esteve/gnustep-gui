/* <title>GSXibLoading</title>

   <abstract>Xib (Cocoa XML) model loader</abstract>

   Copyright (C) 2010 Free Software Foundation, Inc.

   Written by: Fred Kiefer <FredKiefer@gmx.de>
   Created: March 2010
   Refactored slightly by: Gregory Casamento <greg.casamento@gmail.com>
   Created: May 2010

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#ifndef _GNUstep_H_GSXibLoading
#define _GNUstep_H_GSXibLoading

#import <Foundation/NSObject.h>
#import <Foundation/NSKeyedArchiver.h>

@class NSString, NSDictionary, NSArray, NSMutableDictionary, NSMutableArray;

// Hack: This allows the class name FirstResponder in NSCustomObject and
// correctly returns nil as the corresponding object.
@interface FirstResponder: NSObject
{
}
@end

@interface IBClassDescriptionSource: NSObject
{
  NSString *majorKey;
  NSString *minorKey;
}
@end

@interface IBPartialClassDescription: NSObject
{
  NSString *className;
  NSString *superclassName;
  NSMutableDictionary *actions;
  NSMutableDictionary *outlets;
  IBClassDescriptionSource *sourceIdentifier;
}
@end

@interface IBClassDescriber: NSObject
{
  NSMutableArray *referencedPartialClassDescriptions;
}
@end

@interface IBConnection: NSObject <NSCoding>
{
  NSString *label;
  id source;
  id destination;
}
- (id) nibInstantiate;
- (void) establishConnection;
@end

@interface IBActionConnection: IBConnection
{
}
@end

@interface IBOutletConnection: IBConnection
{
}
@end

@interface IBConnectionRecord: NSObject
{
  IBConnection *connection;
  int connectionID;
}
@end

@interface IBObjectRecord: NSObject
{
  int objectID;
  id object;
  id children;
  id parent;
}
- (id) object;
@end

@interface IBMutableOrderedSet: NSObject
{
  NSArray *orderedObjects;
}
- (NSArray *)orderedObjects;
@end

@interface IBObjectContainer: NSObject <NSCoding>
{
  NSMutableArray *connectionRecords;
  IBMutableOrderedSet *objectRecords;
  NSMutableDictionary *flattenedProperties;
  NSMutableDictionary *unlocalizedProperties;
  id activeLocalization;
  NSMutableDictionary *localizations;
  id sourceID;
  int maxID;
}
- (id) nibInstantiate;
- (NSEnumerator *) objectRecordEnumerator;
@end

@interface GSXibElement: NSObject
{
  NSString *type;
  NSDictionary *attributes;
  NSString *value;
  NSMutableDictionary *elements;
  NSMutableArray *values;
}
- (NSString*) type;
- (NSString*) value;
- (NSDictionary*) elements;
- (NSArray*) values;
- (void) addElement: (GSXibElement*)element;
- (void) setElement: (GSXibElement*)element forKey: (NSString*)key;
- (void) setValue: (NSString*)text;
- (NSString*) attributeForKey: (NSString*)key;
- (GSXibElement*) elementForKey: (NSString*)key;
@end

@interface GSXibKeyedUnarchiver: NSKeyedUnarchiver
{
  NSMutableDictionary *objects;
  NSMutableArray *stack;
  GSXibElement *currentElement;
  NSMutableDictionary *decoded;
}
@end

#endif
