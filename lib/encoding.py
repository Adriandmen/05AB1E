# A list of the 05AB1E encoding page in unicode values (256 in total)
osabie_code_page = "\u01DD\u0292\u03B1\u03B2\u03B3\u03B4\u03B5\u03B6\u03B7" \
                   "\u03B8\u000A\u0432\u0438\u043C\u043D\u0442\u0393\u0394" \
                   "\u0398\u03B9\u03A3\u03A9\u2260\u220A\u220D\u221E\u2081" \
                   "\u2082\u2083\u2084\u2085\u2086\u0020\u0021\u0022\u0023" \
                   "\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C" \
                   "\u002D\u002E\u002F\u0030\u0031\u0032\u0033\u0034\u0035" \
                   "\u0036\u0037\u0038\u0039\u003A\u003B\u003C\u003D\u003E" \
                   "\u003F\u0040\u0041\u0042\u0043\u0044\u0045\u0046\u0047" \
                   "\u0048\u0049\u004A\u004B\u004C\u004D\u004E\u004F\u0050" \
                   "\u0051\u0052\u0053\u0054\u0055\u0056\u0057\u0058\u0059" \
                   "\u005A\u005B\u005C\u005D\u005E\u005F\u0060\u0061\u0062" \
                   "\u0063\u0064\u0065\u0066\u0067\u0068\u0069\u006A\u006B" \
                   "\u006C\u006D\u006E\u006F\u0070\u0071\u0072\u0073\u0074" \
                   "\u0075\u0076\u0077\u0078\u0079\u007A\u007B\u007C\u007D" \
                   "\u007E\u01B5\u20AC\u039B\u201A\u0192\u201E\u2026\u2020" \
                   "\u2021\u02C6\u2030\u0160\u2039\u0152\u0106\u017D\u01B6" \
                   "\u0100\u2018\u2019\u201C\u201D\u2022\u2013\u2014\u02DC" \
                   "\u2122\u0161\u203A\u0153\u0107\u017E\u0178\u0101\u00A1" \
                   "\u00A2\u00A3\u00A4\u00A5\u00A6\u00A7\u00A8\u00A9\u00AA" \
                   "\u00AB\u00AC\u03BB\u00AE\u00AF\u00B0\u00B1\u00B2\u00B3" \
                   "\u00B4\u00B5\u00B6\u00B7\u00B8\u00B9\u00BA\u00BB\u00BC" \
                   "\u00BD\u00BE\u00BF\u00C0\u00C1\u00C2\u00C3\u00C4\u00C5" \
                   "\u00C6\u00C7\u00C8\u00C9\u00CA\u00CB\u00CC\u00CD\u00CE" \
                   "\u00CF\u00D0\u00D1\u00D2\u00D3\u00D4\u00D5\u00D6\u00D7" \
                   "\u00D8\u00D9\u00DA\u00DB\u00DC\u00DD\u00DE\u00DF\u00E0" \
                   "\u00E1\u00E2\u00E3\u00E4\u00E5\u00E6\u00E7\u00E8\u00E9" \
                   "\u00EA\u00EB\u00EC\u00ED\u00EE\u00EF\u00F0\u00F1\u00F2" \
                   "\u00F3\u00F4\u00F5\u00F6\u00F7\u00F8\u00F9\u00FA\u00FB" \
                   "\u00FC\u00FD\u00FE\u00FF"


def osabie_to_utf8(code):
    """
    Translates the given code encoded in raw bytes into an 05AB1E
    understandable code
    :param code: The code that needs to be converted into unicode values
    :return: An understandable UTF-8 encoded string for the 05AB1E interpreter
    """

    # Keep the processed unicode values into this string
    processed_code = ""

    # Replace the char with the corresponding character in the 05AB1E code page
    for char in code:
        processed_code += osabie_code_page[ord(char)]

    return processed_code


def utf8_to_osabie(code):
    """
    Translates the given code encoded in UTF-8 into raw osabie bytes
    :param code: The code that needs to be converted into osabie bytes
    :return: A string encoded in osabie bytes
    """

    # Keep the processed byte values into this string
    processed_code = ""

    # Replace the char with the corresponding byte in the 05AB1E code page
    for char in code:
        processed_code += chr(osabie_code_page.index(char))

    return processed_code
