import os
import sys
import inspect
current_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0, parent_dir)

import osabie

tests = os.listdir("test/unit_tests")

EXIT_CODE = 0
TOTAL_TESTS = 0
TOTAL_SUCCESSES = 0
TOTAL_FAILS = 0

for test_file in tests:
    file = open('test/unit_tests/' + test_file, 'r', encoding="UTF-8")

    PASSES = 0
    FAILS = 0
    TOTAL = 0
    LINE_NO = 0

    for line in file:

        LINE_NO += 1

        if "//" in line or len(line) < 2:
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
                        try:
                            expected_results.append(eval(temp.replace("\u00B6", "\n")))
                        except:
                            pass

                        expected_results.append(temp.replace("\u00B6", "\n"))
                        temp = ""

                elif string_mode:
                    temp += Q

            result = ""
            try:
                if test_file == "advanced.tests":
                    temp_file = open("temp_file", "w", encoding="UTF-8")
                    temp_file.write(CODE[5:])
                    temp_file.close()

                    if os.name == 'nt':
                        os.system("py -3 osabie.py temp_file > output_file")
                    else:
                        os.system("python3 osabie.py temp_file > output_file")

                    temp_file = open("output_file", "r", encoding="UTF-8")
                    result = temp_file.read().rstrip("\n")
                    temp_file.close()

                else:
                    result = osabie.run_program(CODE, False, False, True)
            except Exception as e:
                print("An error has occured at line", LINE_NO)
                print(e)
                EXIT_CODE = 1

                osabie.run_program(CODE, True, False, True)

            succeeded = "success" if result in expected_results else "fail"
            print("{}:{}".format(test_file, LINE_NO), "- Test", TOTAL, "-", succeeded)

            if succeeded == "fail":
                print()
                print("FAIL at line", LINE_NO, "in", test_file)
                EXIT_CODE = 1
                if len(expected_results) == 1:
                    print("Expected was", str(expected_results[0]), "but got", result)
                else:
                    print("Expected was one of the following:", expected_results, "but got", result)
                print()

            PASSES += succeeded == "success"
            FAILS += succeeded != "success"

            TOTAL_TESTS += 1

    TOTAL_SUCCESSES += PASSES
    TOTAL_FAILS += FAILS

    print()
    print(TOTAL, "tests run in", test_file)
    print("  Tests passed:", PASSES)
    print("  Tests failed:", FAILS)
    print()

print()
print("---[ RESULT ]------------")
print()
print("Total tests run: ", TOTAL_TESTS)
print("Successes:       ", TOTAL_SUCCESSES)
print("Fails:           ", TOTAL_FAILS)
    
exit(EXIT_CODE)