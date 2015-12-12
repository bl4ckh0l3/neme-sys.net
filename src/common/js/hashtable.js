/*
###########################################################################
# COACH: Component Based Open Source Architecture for                     #
#        Distributed Telecom Applications                                 #
# See:   http://www.objectweb.org/                                        #
#                                                                         #
# Copyright (C) 2003 Lucent Technologies Nederland BV                     #
#                    Bell Labs Advanced Technologies - EMEA               #
#                                                                         #
# Initial developer(s): Wim Hellenthal                                    #
#                                                                         #
# This library is free software; you can redistribute it and/or           #
# modify it under the terms of the GNU Lesser General Public              #
# License as published by the Free Software Foundation; either            #
# version 2.1 of the License, or (at your option) any later version.      #
#                                                                         #
# This library is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of          #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU        #
# Lesser General Public License for more details.                         #
#                                                                         #
# You should have received a copy of the GNU Lesser General Public        #
# License along with this library; if not, write to the Free Software     #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA #
###########################################################################
*/

/**
 * This class implements a hashtable, which maps keys to values.
 */
function Hashtable()
{
    this.hashtable 	= new Array();
}

/**
 * Clears the hashtable so that it contains no keys.
 */
Hashtable.prototype.clear = function()
{
    this.hashtable = new Array();
}

/**
 * Tests if the specified string is a key in the hashtable.
 *
 * @param key Possible key.
 * @returns True if specified string is a key in the hashtable; false otherwise.
 */
Hashtable.prototype.containsKey = function (key)
{
    var exists = false;

    for (var i in this.hashtable)
    {
        if (i == key && this.hashtable[i] != null)
        {
            exists = true;
            break;
        }
    }
    return exists;
}

/**
 * Tests if the specified object is a value in the hashtable.
 *
 * @param value Possible value.
 * @returns True if specified string is a value in the hashtable; false otherwise.
 */
Hashtable.prototype.containsValue = function(value)
{
    var contains = false;

    if (value != null)
    {
        for (var i in this.hashtable)
        {
            if (this.hashtable[i] == value)
            {
                contains = true;
                break;
            }
        }
    }

    return contains;
}

/**
 * Returns the value for the specifies key.
 *
 * @param key Possible key.
 * @returns The value to which the key is mapped in the hashtable; null otherwise.
 */
Hashtable.prototype.get = function(key)
{
    return this.hashtable[key];
}

/**
 * Tests if the hashtable maps no keys to values.
 *
 * @returns True if the hastable contains keys; false if the hashtable is empty.
 */
Hashtable.prototype.isEmpty = function()
{
    return (this.size == 0) ? true : false;
}

/**
 * Returns an array of the keys in the hashtable.
 *
 * @returns An array of the keys in the hashtable.
 */
Hashtable.prototype.keys = function()
{
    var keys = new Array();

    for (var i in this.hashtable)
    {
        if (this.hashtable[i] != null)
            keys.push(i);
    }
    return keys;
}

/**
 * Maps the specified key to the specified value in the hashtable.
 *
 * @param key The hashtable key.
 * @param value The value to associate with the specified key.
 */
Hashtable.prototype.put = function(key, value)
{
    if (key == null || value == null)
    {
        throw "NullPointerException {" + key + "},{" + value + "}";
    }
    else
    {
        this.hashtable[key] = value;
    }
}

/**
 *  Removes the key (and its corresponding value) from the hashtable.
 *
 * @param key The key to remove.
 */
Hashtable.prototype.remove = function(key)
{
    var rtn = this.hashtable[key];

    this.hashtable[key] = null;

    return rtn;
}

/**
 *  Returns the size of the hastable.
 *
 * @returns The size of the hastable.
 */
Hashtable.prototype.size = function()
{
    var size = 0;

    for (var i in this.hashtable)
    {
        if (this.hashtable[i] != null)
            size ++;
    }

    return size;
}

/**
 * Returns the hashtable. This routine is usefull to iterate through the hashtable as shown by the next example: <pre>
 * var table = new Hashtable();
 * var s     = "";
 *
 * table.put ("key1", "Mary ");
 * table.put ("key2", "had ");
 * table.put ("key3", "etc...");
 *
 * for (var i in table.values())
 * {
 *     s&#043=table.values()[i];
 * }
 * </pre>
 *
 * Running the routine will result in the string s containing "Mary had etc..."
 *
 * @returns The hashtable.
 */
Hashtable.prototype.values = function()
{
    return this.hashtable;
}

/**
 * Returns an array of the values in the hashtable.
 *
 * @returns An array of the values in the hashtable.
 */
Hashtable.prototype.toArray = function()
{
	var array = new Array();

	for (var i in this.hashtable )
		array[array.length] = this.hashtable[i];

	return array;
}

