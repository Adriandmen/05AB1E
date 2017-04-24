import os
osabie = __import__("05AB1E")

tests = os.listdir("unittests")

EXIT_CODE = 0

for test_file in tests:
    file = open('unittests/' + test_file, 'r', encoding="UTF-8")

    PASSES = 0
    FAILS = 0
    TOTAL = 0
    LINE_NO = 0

    for line in file:

        LINE_NO += 1

        if line[0:2] == "//" or len(line) < 2:
            continue
        else:
            TOTAL += 1
            if "EXPECT" not in line:
                raise SyntaxError("Following keyword not found in the unit test: 'EXPECT'"
                                  "\n  on line " + str(LINE_NO) + " in file " + test_file)

            CODE = "TEST:" + line.split("EXPECT")[0]
            EXPECTED = line.split("EXPECT")[1]

            temp = ""
            string_mode = False
            expected_results = []
            for Q in EXPECTED:
                if Q == '`':
                    string_mode = not string_mode
                    if not string_mode:
                        expected_results.append(eval(temp.replace("\u00B6", "\n")))
                        temp = ""

                elif string_mode:
                    temp += Q

            result = ""
            try:
                result = osabie.run_program(CODE, False, False, True)
            except Exception:
                print("An error has occured at line", LINE_NO)
                EXIT_CODE = 1

            succeeded = "success" if result in expected_results else "fail"
            print("Test", TOTAL, "-", succeeded)

            if succeeded == "fail":
                print()
                print("FAIL at line", LINE_NO, "in", test_file)
                EXIT_CODE = 1
                if len(expected_results) == 1:
                    print("Expected was", str(expected_results[0]), "but got", result)
                else:
                    print("Expected was one of the following:", expected_results, "but got", result)

            PASSES += succeeded == "success"
            FAILS += succeeded != "success"

    print()
    print(TOTAL, "tests run in", test_file)
    print("  Tests passed:", PASSES)
    print("  Tests failed:", FAILS)
    
exit(EXIT_CODE)